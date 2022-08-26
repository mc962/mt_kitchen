defmodule MTKitchen.Management.Utility.Sluggable do
  import Ecto.Changeset

  # Slug generation happens before checks for required attributes run. Therefore, we need to match on the case when
  #  name might be missing
  # NOTE: This must be before the put_change version of this function as otherwise the slug-generation variant of this
  #   function will match first and produce incorrect behavior.
  def maybe_update_slug(%Ecto.Changeset{changes: %{name: name}} = changeset) when is_nil(name), do: changeset
  def maybe_update_slug(%Ecto.Changeset{valid?: true, changes: %{name: name}} = changeset) do
    put_change(changeset, :slug, generate_slug(name))
  end
  def maybe_update_slug(changeset), do: changeset

  def generate_slug(name) do
    base_slug = name
                |> String.downcase
                |> String.replace(~r/[^a-z0-9\s-]/, "")
                |> String.replace(~r/(\s|-)+/, "-")

    "#{base_slug}-#{generate_random_suffix()}"
  end

  defp generate_random_suffix(length \\ 6) do
    MTKitchen.Accounts.Utility.SecureRandom.urlsafe_base64(length)
  end
end