defmodule MTKitchen.Management.Recipe do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset
  import MTKitchen.Management.Utility.Sluggable

  @max_steps 100

  schema "recipes" do
    field :description, :string
    field :name, :string
    field :publicly_accessible, :boolean, default: false
    field :slug, :string

    field :primary_picture, MtKitchenWeb.Uploaders.Image.Type
    # Delete primary_picture
    field :delete, :boolean, virtual: true

    belongs_to :user, MTKitchen.Accounts.User, type: :binary_id
    has_many :steps, MTKitchen.Management.Step, preload_order: [asc: :order]
    has_many :ingredients, through: [:steps, :ingredients]

    timestamps()
  end

  @doc false
  def information_changeset(recipe, attrs) do
    IO.inspect(recipe, label: "changeset recipe")
    recipe
    |> cast(attrs, [:name, :description, :publicly_accessible, :user_id, :delete])
    # TODO https://www.youtube.com/watch?v=PffpT2eslH8 helped a lot in getting things onto recipe, but still dodesn't quite put it together
    |> cast_attachments(attrs, [:primary_picture])
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
  Makes a stub value for Recipe.order for use in forms when adding a new step, ensuring that the number
  will not intersect with any possible existing step.
  """
  def stubbed_order do
    @max_steps + 1
  end

  def resource_scope do
    "recipes"
  end

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
