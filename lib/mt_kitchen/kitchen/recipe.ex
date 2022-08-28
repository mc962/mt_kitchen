defmodule MTKitchen.Kitchen.Recipe do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recipes" do
    field :description, :string
    field :name, :string
    field :publicly_accessible, :boolean, default: false
    field :slug, :string

    belongs_to :user, MTKitchen.Accounts.User, type: :binary_id
    has_many :steps, MTKitchen.Kitchen.Step, preload_order: [asc: :order]
    has_many :ingredients, through: [:steps, :ingredients]

    timestamps()
  end

  @doc false
  def changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:name, :slug, :description, :publicly_accessible, :user_id])
    |> cast_assoc(:steps)
  end
end
