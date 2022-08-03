defmodule MTKitchen.Management.Step do
  use Ecto.Schema
  import Ecto.Changeset

  schema "steps" do
    field :instruction, :string
    field :order, :integer

    belongs_to :recipe, MTKitchen.Management.Recipe
    has_many :step_ingredients, MTKitchen.Management.StepIngredient
    has_many :ingredients, through: [:step_ingredients, :ingredient]

    timestamps()
  end

  @doc false
  def changeset(step, attrs) do
    step
    |> cast(attrs, [:order, :instruction])
    |> validate_required([:order, :instruction])
    |> validate_number(:order, greater_than: 0)
    |> assoc_constraint(:recipe)
    |> cast_assoc(:step_ingredients)
  end
end
