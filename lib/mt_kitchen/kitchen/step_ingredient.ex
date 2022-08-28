defmodule MTKitchen.Kitchen.StepIngredient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "step_ingredients" do
    field :amount, :decimal
    field :condition, :string
    field :unit, :string

    belongs_to :step, MTKitchen.Kitchen.Step
    belongs_to :ingredient, MTKitchen.Kitchen.Ingredient

    timestamps()
  end

  @doc false
  def changeset(step_ingredient, attrs) do
    step_ingredient
    |> cast(attrs, [:amount, :unit, :condition])
    |> cast_assoc(:ingredient)
  end
end
