defmodule MTKitchen.Management.Step do
  use Ecto.Schema
  import Ecto.Changeset

  schema "steps" do
    field :instruction, :string
    field :order, :integer

    field :delete, :boolean, virtual: true

    belongs_to :recipe, MTKitchen.Management.Recipe
    has_many :step_ingredients, MTKitchen.Management.StepIngredient
    has_many :ingredients, through: [:step_ingredients, :ingredient]

    timestamps()
  end

  @doc false
  def changeset(step, attrs) do
    step
    |> cast(attrs, [:order, :instruction, :delete])
    |> validate_required([:order, :instruction])
    |> validate_number(:order, greater_than: 0)
    |> assoc_constraint(:recipe)
    |> cast_assoc(:step_ingredients)
    |> maybe_mark_for_deletion()
  end

  # If primary key id is nil / record is not persisted, then we will never mark for deletion
  # TODO eliminate if/else in other Schemas with this type of pattern matching
  defp maybe_mark_for_deletion(%{data: %{id: nil}} = changeset), do: changeset
  # If record is currently persisted, and we noted in params that the record should be deleted, then mark in the
  #   [Changeset Action](https://hexdocs.pm/ecto/Ecto.Changeset.html#module-changeset-actions) to delete that record.
  defp maybe_mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
