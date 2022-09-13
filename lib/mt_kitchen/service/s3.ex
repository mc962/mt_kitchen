defmodule MTKitchen.Service.S3 do
  @moduledoc """
  Dependency-free S3 Form Upload using HTTP POST sigv4
  https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-post-example.html
  """

  @doc """
  Signs a form upload.
  The configuration is a map which must contain the following keys:
    * `:region` - The AWS region, such as "us-east-1"
    * `:access_key_id` - The AWS access key id
    * `:secret_access_key` - The AWS secret access key
  Returns a map of form fields to be used on the client via the JavaScript `FormData` API.

  ## Options
    * `:key` - The required key of the object to be uploaded.
    * `:max_file_size` - The required maximum allowed file size in bytes.
    * `:content_type` - The required MIME type of the file to be uploaded.
    * `:expires_in` - The required expiration time in milliseconds from now
      before the signed upload expires.
  ## Examples
      config = %{
        region: "us-east-1",
        access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
        secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
      }
      {:ok, fields} =
        MTKitchenWeb.S3.sign_form_upload(config, "my-bucket",
          key: "public/my-file-name",
          content_type: "image/png",
          max_file_size: 10_000,
          expires_in: :timer.hours(1)
        )
  """
  def sign_form_upload(config, bucket, opts) do
    key = Keyword.fetch!(opts, :key)
    max_file_size = Keyword.fetch!(opts, :max_file_size)
    content_type = Keyword.fetch!(opts, :content_type)
    expires_in = Keyword.fetch!(opts, :expires_in)

    expires_at = DateTime.add(DateTime.utc_now(), expires_in, :millisecond)
    amz_date = amz_date(expires_at)
    credential = credential(config, expires_at)

    encoded_policy =
      Base.encode64("""
      {
        "expiration": "#{DateTime.to_iso8601(expires_at)}",
        "conditions": [
          {"bucket":  "#{bucket}"},
          ["eq", "$key", "#{key}"],
          {"acl": "public-read"},
          ["eq", "$Content-Type", "#{content_type}"],
          ["content-length-range", 0, #{max_file_size}],
          {"x-amz-server-side-encryption": "AES256"},
          {"x-amz-credential": "#{credential}"},
          {"x-amz-algorithm": "AWS4-HMAC-SHA256"},
          {"x-amz-date": "#{amz_date}"}
        ]
      }
      """)

    fields = %{
      "key" => key,
      "acl" => "public-read",
      "content-type" => content_type,
      "x-amz-server-side-encryption" => "AES256",
      "x-amz-credential" => credential,
      "x-amz-algorithm" => "AWS4-HMAC-SHA256",
      "x-amz-date" => amz_date,
      "policy" => encoded_policy,
      "x-amz-signature" => signature(config, expires_at, encoded_policy)
    }

    {:ok, fields}
  end

  @doc """
  Builds an S3 host for creating a valid link together with an S3 key for display in an img tag preview image.
  """
  def host do
    # Build the correct domain pointing to the bucket based on configuration. As port is only used locally to point to
    #   the local Object Store, filter that information out of the final domain in a non-dev environment.
    domain =
      [
        Application.get_env(:ex_aws, :s3)[:host],
        Application.get_env(:ex_aws, :s3)[:port]
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(":")

    "//#{domain}/#{Application.get_env(:ex_aws, :s3)[:bucket]}"
  end

  @doc """
  Builds a key to an image for a resource in the Object Store

  ## Examples

      iex> resource_image_key(%Phoenix.LiveView.UploadEntry{}, "recipes")
      "assets/images/resources/dev/recipes/tasty-food.jpeg"

      iex> resource_image_key(%Phoenix.LiveView.UploadEntry{})
      "assets/images/resources/dev/tasty-food.jpeg"
  """
  def resource_image_key(entry, resource \\ nil) do
    storage_dir_parts = %{
      prefix: "assets/images/resources",
      env: Application.get_env(:ex_aws, :s3)[:storage_env],
      resource: resource
    }

    # Filter out any parts used to build the "directory" that the image is stored in that are not defined.
    prefix =
      [
        storage_dir_parts[:prefix],
        storage_dir_parts[:env],
        storage_dir_parts[:resource]
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("/")

    "#{prefix}/#{Path.basename(entry.client_name, Path.extname(entry.client_name))}-#{entry.uuid}#{Path.extname(entry.client_name)}"
  end

  @doc """
  Uploads a file stored on the server at a particular path to the Object Store at a particular key.

  ## Examples

      iex> upload("/path/to/upload/file.ext", %Phoenix.LiveView.UploadEntry{})
      {:ok, _result}
  """
  def upload(path, entry) do
    bucket = Application.get_env(:ex_aws, :s3)[:bucket]
    key = resource_image_key(entry, "recipes")

    path
    |> ExAws.S3.Upload.stream_file()
    |> ExAws.S3.upload(bucket, key, acl: :public_read)
    |> ExAws.request()
  end

  @doc """
  Deletes a file stored in the Object Store at a particular key.

  ## Examples

      iex> delete("assets/images/resources/dev/recipes/tasty-food.jpeg")
      {:ok, _result}
  """
  def delete(key) do
    bucket = Application.get_env(:ex_aws, :s3)[:bucket]

    ExAws.S3.delete_object(bucket, key)
    |> ExAws.request()
  end

  # Calculates a valid valid for the x-amz-date metadata field for a signed link.
  defp amz_date(time) do
    time
    |> NaiveDateTime.to_iso8601()
    |> String.split(".")
    |> List.first()
    |> String.replace("-", "")
    |> String.replace(":", "")
    |> Kernel.<>("Z")
  end

  # Calculates a value for the x-amz-credential metadata field for a signed link.
  defp credential(%{} = config, %DateTime{} = expires_at) do
    "#{config.access_key_id}/#{short_date(expires_at)}/#{config.region}/s3/aws4_request"
  end

  # Calculates a value for the x-amz-signature metadata field for a signed link.
  defp signature(config, %DateTime{} = expires_at, encoded_policy) do
    config
    |> signing_key(expires_at, "s3")
    |> sha256(encoded_policy)
    |> Base.encode16(case: :lower)
  end

  # Calculates the value of the signing key used to generate the x-amz-signature metadata field.
  defp signing_key(%{} = config, %DateTime{} = expires_at, service) when service in ["s3"] do
    amz_date = short_date(expires_at)
    %{secret_access_key: secret, region: region} = config

    ("AWS4" <> secret)
    |> sha256(amz_date)
    |> sha256(region)
    |> sha256(service)
    |> sha256("aws4_request")
  end

  # Builds a shorter version of a DateTime string used to calculate various metadata fields.
  defp short_date(%DateTime{} = expires_at) do
    expires_at
    |> amz_date()
    |> String.slice(0..7)
  end

  # Calculates an HMAC code based on passed data
  defp sha256(secret, msg), do: :crypto.mac(:hmac, :sha256, secret, msg)
end
