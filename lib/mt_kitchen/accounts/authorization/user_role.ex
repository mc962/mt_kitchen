defmodule MTKitchen.Accounts.Authorization.UserRole do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "user_roles" do
    belongs_to :user, MTKitchen.Accounts.User, type: :binary_id, primary_key: true
    belongs_to :role, MTKitchen.Accounts.Authorization.Role, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(user_role, attrs) do
    user_role
    |> cast(attrs, [:user_id, :role_id])
    |> cast_assoc(:role)
    |> assoc_constraint(:user)
    |> unique_constraint(:role_id, name: "user_roles_pkey")
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:role_id)
  end
end
