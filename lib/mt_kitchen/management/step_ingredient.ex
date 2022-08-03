defmodule MTKitchen.Management.StepIngredient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "step_ingredients" do
    field :amount, :decimal
    field :condition, :string
    field :unit, :string

    belongs_to :step, MTKitchen.Management.Step
    belongs_to :ingredient, MTKitchen.Management.Ingredient

    timestamps()
  end

  @doc false
  def changeset(step_ingredient, attrs) do
    step_ingredient
    |> cast(attrs, [:amount, :unit, :condition])
    |> validate_required([:amount, :unit, :condition])
    |> assoc_constraint(:step)
    |> cast_assoc(:ingredient)
    |> foreign_key_constraint(:step_id)
    |> foreign_key_constraint(:ingredient_id)
  end
end
