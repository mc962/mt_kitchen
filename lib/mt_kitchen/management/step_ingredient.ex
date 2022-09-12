defmodule MTKitchen.Management.StepIngredient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "step_ingredients" do
    field :amount, :decimal
    field :condition, :string
    field :unit, :string

    field :delete, :boolean, virtual: true
    field :temp_id, :string, virtual: true

    belongs_to :step, MTKitchen.Management.Step
    belongs_to :ingredient, MTKitchen.Management.Ingredient

    timestamps()
  end

  @doc false
  def changeset(step_ingredient, attrs) do
    step_ingredient
    # So its persisted
    |> Map.put(:temp_id, step_ingredient.temp_id || attrs["temp_id"])
    |> cast(attrs, [:amount, :unit, :condition, :delete])
    |> validate_required([:amount])
    |> assoc_constraint(:step)
    |> cast_assoc(:ingredient)
    |> foreign_key_constraint(:step_id)
    |> foreign_key_constraint(:ingredient_id)
    |> foreign_key_constraint(:user_id)
    |> maybe_mark_for_deletion()
  end

  # If primary key id is nil / record is not persisted, then we will never mark for deletion
  defp maybe_mark_for_deletion(%{data: %{id: nil}} = changeset) do
    changeset
  end

  # If record is currently persisted, and we noted in params that the record should be deleted, then mark in the
  #   [Changeset Action](https://hexdocs.pm/ecto/Ecto.Changeset.html#module-changeset-actions) to delete that record.
  defp maybe_mark_for_deletion(
         %Ecto.Changeset{valid?: true, changes: %{delete: true}} = changeset
       ) do
    %{changeset | action: :delete}
  end

  # All other changesets that don't satisfy these conditions should just be passed through
  defp maybe_mark_for_deletion(changeset), do: changeset
end
