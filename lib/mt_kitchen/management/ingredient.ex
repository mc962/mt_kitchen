defmodule MTKitchen.Management.Ingredient do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset
  import MTKitchen.Management.Utility.Sluggable

  schema "ingredients" do
    field :ancestry, :string
    field :description, :string
    field :name, :string
    field :slug, :string

    field :primary_picture, MtKitchenWeb.Uploaders.Image.Type

    belongs_to :user, MTKitchen.Accounts.User, type: :binary_id
    has_many :step_ingredients, MTKitchen.Management.StepIngredient
    has_many :steps, through: [:step_ingredients, :step]
    has_many :recipes, through: [:steps, :recipe]

    timestamps()
  end

  @doc false
  def changeset(ingredient, attrs) do
    ingredient
    |> cast(attrs, [:name, :slug, :description, :ancestry, :user_id])
    |> maybe_update_slug()
    |> validate_required([:name, :slug])
    |> assoc_constraint(:user)
    |> unique_constraint([:name, :user_id])
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:user_id)
    |> on_conflict_upsert()
  end

  defp on_conflict_upsert(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> Map.put(:repo_opts,
      on_conflict: [set: [name: get_change(changeset, :name)]],
      conflict_target: [:name, :user_id]
    )
  end

  defp on_conflict_upsert(changeset), do: changeset
end
