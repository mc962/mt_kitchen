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
    |> set_slug_if_changed()
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
      #    |> remove_deleted_steps()
    |> consolidate_step_order()
    |> set_slug_if_changed()
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

  defp consolidate_step_order(recipe) do
    if get_change(recipe, :steps) do
      steps = get_change(recipe, :steps)
              |> Stream.with_index(1)
              |> Enum.map(fn {step, new_order} -> put_change(step, :order, new_order) end)

      put_assoc(recipe, :steps, steps)
    else
      recipe
    end
  end

  defp set_slug_if_changed(recipe) do
    # TODO basic slugging function before making something more robust
    if get_change(recipe, :name) do
      put_change(recipe, :slug, generate_slug(get_change(recipe, :name)))
    else
      recipe
    end
  end

  defp generate_slug(name) do
    name
    |> String.downcase
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/(\s|-)+/, "-")
  end
end
