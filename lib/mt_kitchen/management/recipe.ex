defmodule MTKitchen.Management.Recipe do
  use Ecto.Schema
  import Ecto.Changeset
  import MTKitchen.Management.Utility.Sluggable

  #  @max_steps 100

  schema "recipes" do
    field :description, :string
    field :name, :string
    field :publicly_accessible, :boolean, default: false
    field :slug, :string

    field :primary_picture, :string
    # Delete primary_picture
    field :delete, :boolean, virtual: true

    belongs_to :user, MTKitchen.Accounts.User, type: :binary_id
    has_many :steps, MTKitchen.Management.Step, preload_order: [asc: :order]
    has_many :ingredients, through: [:steps, :ingredients]

    timestamps()
  end

  @doc false
  def information_changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [
      :name,
      :description,
      :primary_picture,
      :publicly_accessible,
      :user_id,
      :delete
    ])
    |> cast_assoc(:steps)
    |> maybe_update_slug()
    |> validate_required([:name, :slug, :publicly_accessible])
    |> unique_constraint([:name, :user_id])
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:user_id)
    |> maybe_delete_image()
  end

  @doc false
  def recipe_steps_changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:user_id])
    |> cast_assoc(:steps)
    |> assoc_constraint(:user)
    |> maybe_consolidate_step_order()
    |> maybe_update_slug()
    |> unique_constraint([:name, :user_id])
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:user_id)
  end

  @doc """
  Provide a String representing a valid key in Object Store bucket pointing to the Recipe primary_picture for use in
    viewing/previewing and the primary_picture image. If none has been uploaded yet, then fallback to the default.

  NOTE: Images at provided Object Store keys are expected to exist in the target bucket.
  """
  def preview_primary_picture(recipe),
    do: recipe.primary_picture || MTKitchen.Management.default_preview_image()

  defp maybe_consolidate_step_order(
         %Ecto.Changeset{valid?: true, changes: %{steps: _steps}} = recipe
       ) do
    #    new_order = 1
    #    # TODO this still doesn't appear to work, but currently is harmless so will fix later
    #    steps
    #    |> Enum.map(fn step ->
    #        unless step.action == :delete do
    #          # Only count a step for re-ordering if it is not getting deleted.
    #          put_change(step, :order, new_order)
    #          new_order = ^new_order + 1
    #        end
    #      end)
    #
    #    put_assoc(recipe, :steps, steps)
    recipe
  end

  defp maybe_consolidate_step_order(recipe), do: recipe

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
