defmodule MTKitchen.Management.Ingredient do
  use Ecto.Schema
  import Ecto.Changeset
  import MTKitchen.Management.Utility.Sluggable

  schema "ingredients" do
    field :ancestry, :string
    field :description, :string
    field :name, :string
    field :slug, :string

    field :primary_picture, :string
    # Delete primary_picture
    field :delete, :boolean, virtual: true

    belongs_to :user, MTKitchen.Accounts.User, type: :binary_id
    has_many :step_ingredients, MTKitchen.Management.StepIngredient
    has_many :steps, through: [:step_ingredients, :step]
    has_many :recipes, through: [:steps, :recipe]

    timestamps()
  end

  @doc false
  def changeset(ingredient, attrs) do
    ingredient
    |> cast(attrs, [:name, :slug, :description, :ancestry, :primary_picture, :user_id])
    |> maybe_update_slug()
    |> validate_required([:name, :slug])
    |> assoc_constraint(:user)
    |> unique_constraint([:name, :user_id])
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:user_id)
    |> on_conflict_upsert()
    |> maybe_delete_image()
  end

  defp on_conflict_upsert(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> Map.put(:repo_opts,
      on_conflict: [set: [name: get_change(changeset, :name)]],
      conflict_target: [:name, :user_id]
    )
  end

  defp on_conflict_upsert(changeset), do: changeset

  # If primary key id is nil / record is not persisted, then we will never mark for deletion
  defp maybe_delete_image(%{data: %{id: nil}} = changeset), do: changeset

  # If record is currently persisted, and we noted in params that the record should be deleted, then mark in the
  #   [Changeset Action](https://hexdocs.pm/ecto/Ecto.Changeset.html#module-changeset-actions) to delete that record.
  defp maybe_delete_image(%Ecto.Changeset{valid?: true, changes: %{delete: true}} = changeset) do
    put_change(changeset, :primary_picture, nil)
  end

  # All other changesets that don't satisfy these conditions should just be passed through
  defp maybe_delete_image(changeset), do: changeset
end
