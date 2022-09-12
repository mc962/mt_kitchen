defmodule MTKitchen.Management.Utility.Uploadable do
  alias Phoenix.LiveView.Upload
  alias MTKitchen.Service.S3

  @doc """
  Extracts information to generate Object Store keys from entries that have finished uploading to the Server.
    This information is what will be attached to the Ecto Schema and stored in the database.

  ## Examples

      iex> extract_entry_key(%Phoenix.Socket{}, :primary_picture, "recipes", true)
      "assets/images/resources/dev/recipes/tasty-food.jpeg"

      iex> extract_entry_key(%Phoenix.Socket{}, :primary_picture, "recipes", false)
      ["assets/images/resources/dev/recipes/tasty-food.jpeg"]
  """
  def extract_entry_key(socket, namespace, resource \\ nil, single \\ false) do
    {completed, []} = Upload.uploaded_entries(socket, namespace)

    keys =
      for entry <- completed do
        S3.resource_image_key(entry, resource)
      end

    if single do
      List.first(keys)
    else
      keys
    end
  end

  @doc """
  Extracts information to generate Object Store keys from entries, generates an appropriate Object Store key from the
    uploaded resource file metadata, and uploads the file to the Object Store from where it is stored on the Server.

  ## Examples

      iex> consume_attachments(%Phoenix.Socket{}, %Recipe{}, :primary_picture, "recipes")
        {:ok, recipe}
  """
  def consume_attachments(socket, schema, namespace, resource) do
    Upload.consume_uploaded_entries(socket, namespace, fn %{path: path}, entry ->
      case S3.upload(path, entry) do
        {:ok, _result} ->
          {:ok, "#{S3.host()}/#{S3.resource_image_key(entry, resource)}"}

        {:error, err} ->
          {:error, err}
      end
    end)

    {:ok, schema}
  end
end
