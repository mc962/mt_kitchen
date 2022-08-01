defmodule MTKitchen.Management.Ingredient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ingredients" do
    field :ancestry, :string
    field :description, :string
    field :name, :string
    field :slug, :string

    belongs_to :user, MTKitchen.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(ingredient, attrs) do
    ingredient
    |> cast(attrs, [:name, :slug, :description, :ancestry])
    |> validate_required([:name, :slug, :description, :ancestry])
    |> assoc_constraint(:user)
    |> set_slug_if_changed()
    |> unique_constraint([:name, :user_id])
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:user_id)
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
