defmodule MTKitchen.Kitchen.Ingredient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ingredients" do
    field :ancestry, :string
    field :description, :string
    field :name, :string
    field :slug, :string

    belongs_to :user, MTKitchen.Accounts.User, type: :binary_id
    has_many :step_ingredients, MTKitchen.Kitchen.StepIngredient
    has_many :steps, through: [:step_ingredients, :step]
    has_many :recipes, through: [:steps, :recipe]

    timestamps()
  end

  @doc false
  def changeset(ingredient, attrs) do
    ingredient
    |> cast(attrs, [:name, :slug, :description, :ancestry, :user_id])
  end
end
