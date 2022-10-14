defmodule MTKitchen.Accounts.Authorization.Role do
  use Ecto.Schema
  import Ecto.Changeset

  @allowed [
    {"Superuser", :superuser},
    {"Administrator", :administrator},
    {"Moderator", :moderator},
    {"Editor", :editor},
  ]

  schema "roles" do
    field :name, :string

    many_to_many :users, MTKitchen.Accounts.User,
      join_through: MTKitchen.Accounts.Authorization.UserRole

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

  def promotion_changeset(role, attrs) do
    role
    |> cast(attrs, [:name])
    |> cast_assoc(:user_roles)
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> Map.put(:repo_opts,
      on_conflict: [set: [name: get_change(role, :name)]],
      conflict_target: [:name]
    )
  end

  def allowed, do: @allowed
end
