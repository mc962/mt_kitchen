defmodule MTKitchen.Management.Recipe do
  use Ecto.Schema
  import Ecto.Changeset

  @max_steps 100

  schema "recipes" do
    field :description, :string
    field :name, :string
    field :publicly_accessible, :boolean, default: false
    field :slug, :string

    belongs_to :user, MTKitchen.Accounts.User
    has_many :steps, MTKitchen.Management.Step
    has_many :ingredients, through: [:steps, :ingredients]

    timestamps()
  end

  @doc false
  def information_changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:name, :slug, :description, :publicly_accessible, :user_id])
    |> cast_assoc(:steps)
    |> validate_required([:name, :slug, :publicly_accessible])
    |> maybe_update_slug()
    |> unique_constraint([:name, :user_id])
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:user_id)
  end

  @doc false
  def steps_changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:name, :slug, :description, :publicly_accessible, :user_id])
    |> cast_assoc(:steps)
    |> validate_required([:name, :publicly_accessible])
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

#  TODO this needs to happen _after_ db changes, otherwise step order will not be consolidated in relation to changed records
  defp maybe_consolidate_step_order(recipe), do: recipe
  defp maybe_consolidate_step_order(%Ecto.Changeset{valid?: true, changes: %{steps: steps}} = recipe) do
    steps
    |> Stream.with_index(1)
    |> Enum.map(fn {step, new_order} -> put_change(step, :order, new_order) end)

    put_assoc(recipe, :steps, steps)
  end

  defp maybe_update_slug(recipe), do: recipe
  defp maybe_update_slug(%Ecto.Changeset{valid?: true, changes: %{name: name}} = recipe) do
    put_change(recipe, :slug, generate_slug(get_change(recipe, :name)))
  end

  defp generate_slug(name) do
    name
    |> String.downcase
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/(\s|-)+/, "-")
  end
end
