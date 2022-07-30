defmodule MTKitchen.Management.Recipe do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recipes" do
    field :description, :string
    field :name, :string
    field :publicly_accessible, :boolean, default: false
    field :slug, :string

    belongs_to :user, MTKitchen.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:name, :slug, :description, :publicly_accessible, :user_id])
    |> set_slug_if_changed()
    |> validate_required([:name, :slug, :publicly_accessible])
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
