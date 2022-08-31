defmodule MtKitchenWeb.Uploaders.Image do
  use Waffle.Definition

  # Include ecto support (requires package waffle_ecto installed):
  use Waffle.Ecto.Definition

  @versions [:original]

  # To add a thumbnail version:
  # @versions [:original, :thumb]

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end

  # def bucket({_file, scope}) do
  #   scope.bucket || bucket()
  # end

  # Whitelist file extensions:
  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()

    case Enum.member?(~w(.jpg .jpeg .gif .png), file_extension) do
      true -> :ok
      false -> {:error, "invalid file type"}
    end
  end

  # Define a thumbnail transformation:
  # def transform(:thumb, _) do
  #   {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  # end

  # Override the persisted filenames:
  # def filename(version, _) do
  #   version
  # end

  # Override the storage directory:
  def storage_dir(_version, {_file, scope}) do
    storage_dir_parts = %{
      prefix: "/assets/images/resources",
      env: "",
      resource: scope.__struct__.resource_scope()
    }

    storage_dir_parts =
      if Application.get_env(:mt_kitchen, :env) == :prod do
        Map.put(storage_dir_parts, :env, "live")
      else
        Map.put(storage_dir_parts, :env, "dev")
      end

    "#{storage_dir_parts[:prefix]}/#{storage_dir_parts[:env]}/#{storage_dir_parts[:resource]}"
  end

  # Provide a default URL if there hasn't been a file uploaded
  def default_url(_version, _scope) do
    "/assets/images/site/default_food.jpeg"
  end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  def s3_object_headers(_version, {file, _scope}) do
    [
      content_type: MIME.from_path(file.file_name),
      cache_control: "public, max-age=31536000",
      # Expires 1 year from now, converted to format compatible with Expires header
      expires:
        (:calendar.datetime_to_gregorian_seconds(:erlang.universaltime()) + 365 * 24 * 60 * 60)
        |> :calendar.gregorian_seconds_to_datetime()
        |> :httpd_util.rfc1123_date()
    ]
  end
end
