defmodule MTKitchen.Management.Utility.PublicResourceable do
  import Ecto.Changeset

  # Resolve User's public ID to private internal id, only if the changeset is still valid and the
  #  user_id has not already been assigned.
  def maybe_resolve_public_user_id(%Ecto.Changeset{valid?: true, changes: %{user_id: user_id}} = changeset) do
    case MTKitchen.Accounts.get_user_by_public_id(user_id) do
      {:ok, user} -> put_change(changeset, :user_id, user.id)
      {:error, _} -> add_error(changeset, :user_id, "user to associate record with was not found")
    end
  end
  def maybe_resolve_public_user_id(changeset), do: changeset
end
