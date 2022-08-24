defmodule MTKitchen.Accounts.UserRole do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "user_roles" do
    belongs_to :user, MTKitchen.Accounts.User, type: :binary_id, primary_key: true
    belongs_to :role, MTKitchen.Accounts.Role, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(user_role, attrs) do
    user_role
    |> cast(attrs, [:user_id, :role_id])
    |> validate_required([:user_id, :role_id])
    |> unique_constraint(:role_id, name: "user_roles_pkey")
  end
end
