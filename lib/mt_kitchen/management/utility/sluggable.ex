defmodule MTKitchen.Management.Utility.Sluggable do
  import Ecto.Changeset

  def maybe_update_slug(%Ecto.Changeset{valid?: true, changes: %{name: name}} = changeset) do
    put_change(changeset, :slug, generate_slug(name))
  end
  def maybe_update_slug(changeset), do: changeset

  defp generate_slug(name) do
    base_slug = name
                |> String.downcase
                |> String.replace(~r/[^a-z0-9\s-]/, "")
                |> String.replace(~r/(\s|-)+/, "-")

    "#{base_slug}-#{generate_random_suffix()}"
  end

  defp generate_random_suffix(length \\ 6) do
    MTKitchen.Accounts.SecureRandom.urlsafe_base64(length)
  end
end