defmodule MTKitchen.Management.Recipe do
  use Ecto.Schema
  import Ecto.Changeset
  import MTKitchen.Management.Utility.Sluggable
  import MTKitchen.Management.Utility.PublicResourceable

  @max_steps 100

  schema "recipes" do
    field :description, :string
    field :name, :string
    field :publicly_accessible, :boolean, default: false
    field :slug, :string

    belongs_to :user, MTKitchen.Accounts.User, type: :binary_id
    has_many :steps, MTKitchen.Management.Step, preload_order: [asc: :order]
    has_many :ingredients, through: [:steps, :ingredients]

    timestamps()
  end

  @doc false
  def information_changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:name, :slug, :description, :publicly_accessible, :user_id])
    |> cast_assoc(:steps)
    |> maybe_update_slug()
    |> maybe_resolve_public_user_id()
    |> validate_required([:name, :slug, :publicly_accessible])
    |> unique_constraint([:name, :user_id])
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:user_id)
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

  def default_primary_picture_key do
    "site/default_food.jpg"
  end

  defp maybe_consolidate_step_order(%Ecto.Changeset{valid?: true, changes: %{steps: _steps}} = recipe) do
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
end
