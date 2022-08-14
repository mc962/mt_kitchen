defmodule MTKitchen.Management.Recipe do
  use Ecto.Schema
  import Ecto.Changeset

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

  defp maybe_update_slug(%Ecto.Changeset{valid?: true, changes: %{name: name}} = recipe) do
    put_change(recipe, :slug, generate_slug(name))
  end
  defp maybe_update_slug(recipe), do: recipe

  defp generate_slug(name) do
    base_slug = name
                |> String.downcase
                |> String.replace(~r/[^a-z0-9\s-]/, "")
                |> String.replace(~r/(\s|-)+/, "-")

    "#{base_slug}-#{generate_random_suffix()}"
  end

  defp generate_random_suffix(length \\ 6) do
    SecureRandom.urlsafe_base64(length)
  end

  # Resolve User's public ID to private internal id, only if the changeset is still valid and the
  #  user_id has not already been assigned.
  defp maybe_resolve_public_user_id(%Ecto.Changeset{valid?: true, changes: %{user_id: user_id}} = changeset) do
    case MTKitchen.Accounts.get_user_by_public_id(user_id) do
      {:ok, user} -> put_change(changeset, :user_id, user.id)
      {:error, _} -> add_error(changeset, :user_id, "user to associate record with was not found")
    end
  end
  defp maybe_resolve_public_user_id(changeset), do: changeset
end
