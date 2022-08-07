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
  defp maybe_mark_for_deletion(%{data: %{id: nil}} = changeset), do: changeset
  # If record is currently persisted, and we noted in params that the record should be deleted, then mark in the
  #   [Changeset Action](https://hexdocs.pm/ecto/Ecto.Changeset.html#module-changeset-actions) to delete that record.
  defp maybe_mark_for_deletion(%Ecto.Changeset{valid?: true, changes: %{delete: _delete}} = changeset) do
    IO.puts("DELETE IT")
    %{changeset | action: :delete}
  end
  # All other changesets that don't satisfy these conditions should just be passed through
  defp maybe_mark_for_deletion(changeset), do: changeset
end
