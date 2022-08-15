defmodule MTKitchen.Management.Ingredient do
  use Ecto.Schema
  import Ecto.Changeset
  import MTKitchen.Management.Utility.Sluggable
  import MTKitchen.Management.Utility.PublicResourceable

  schema "ingredients" do
    field :ancestry, :string
    field :description, :string
    field :name, :string
    field :slug, :string

    belongs_to :user, MTKitchen.Accounts.User, type: :binary_id
    has_many :step_ingredients, MTKitchen.Management.StepIngredient
    has_many :steps, through: [:step_ingredients, :step]
    has_many :recipes, through: [:steps, :recipe]

    timestamps()
  end

  @doc false
  def changeset(ingredient, attrs) do
    ingredient
    |> cast(attrs, [:name, :slug, :description, :ancestry, :user_id])
    # We can't insert current user_id value into Ingredient as it's the UUID User.public_id, not the internal primary key id,
    #   and so need to resolve this sort of thing separately.
#    |> maybe_resolve_public_user_id()
    |> maybe_update_slug()
    |> validate_required([:name, :slug])
    |> assoc_constraint(:user)
    |> unique_constraint([:name, :user_id])
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:user_id)
  end
end
