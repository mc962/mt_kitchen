defmodule MTKitchen.Management.Ingredient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ingredients" do
    field :ancestry, :string
    field :description, :string
    field :name, :string
    field :slug, :string

    belongs_to :user, MTKitchen.Accounts.User
    has_many :step_ingredients, MTKitchen.Management.StepIngredient
    has_many :steps, through: [:step_ingredients, :step]
    has_many :recipes, through: [:steps, :recipe]

    timestamps()
  end

  @doc false
  def changeset(ingredient, attrs) do
    new_ingredient = ingredient
    |> cast(attrs, [:name, :slug, :description, :ancestry])
    |> maybe_update_slug()
    |> validate_required([:name, :slug])
    |> assoc_constraint(:user)
    |> unique_constraint([:name, :user_id])
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:user_id)

    IO.inspect(attrs)
    IO.puts "new_ingredient"
    IO.inspect(new_ingredient)

    new_ingredient
  end

  defp maybe_update_slug(%Ecto.Changeset{valid?: true, changes: %{name: name}} = ingredient) do
    put_change(ingredient, :slug, generate_slug(name))
  end
  defp maybe_update_slug(ingredient), do: ingredient

  defp generate_slug(name) do
    name
    |> String.downcase
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/(\s|-)+/, "-")
  end
end
