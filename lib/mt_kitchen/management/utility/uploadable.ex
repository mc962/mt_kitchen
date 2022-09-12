defmodule MTKitchen.Management.Utility.Uploadable do
  alias Phoenix.LiveView.Upload
  alias MTKitchen.Service.S3

  def extract_entry_url(socket, namespace, resource \\ nil, single \\ false) do
    {completed, []} = Upload.uploaded_entries(socket, namespace)

    urls =
      for entry <- completed do
        S3.key(entry, resource)
      end

    if single do
      List.first(urls)
    else
      urls
    end
  end

  def consume_attachments(socket, schema, namespace, resource) do
    Upload.consume_uploaded_entries(socket, namespace, fn %{path: path}, entry ->
      case S3.upload(path, entry) do
        {:ok, _result} ->
          {:ok, "#{S3.host()}/#{S3.key(entry, resource)}"}

        {:error, err} ->
          {:error, err}
      end
    end)

    {:ok, schema}
  end
end