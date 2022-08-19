defmodule MTKitchen.Kitchen.Step do
  use Ecto.Schema
  import Ecto.Changeset

  schema "steps" do
    field :instruction, :string
    field :order, :integer

    belongs_to :recipe, MTKitchen.Kitchen.Recipe
    has_many :step_ingredients, MTKitchen.Kitchen.StepIngredient
    has_many :ingredients, through: [:step_ingredients, :ingredient] # TODO preload_order ingredient name on has_many/through

    timestamps()
  end

  @doc false
  def changeset(step, attrs) do
    step
    |> cast(attrs, [:order, :instruction, :recipe_id])
    |> cast_assoc(:step_ingredients)
  end
end
