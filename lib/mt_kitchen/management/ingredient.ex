defmodule MTKitchen.Management.Ingredient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ingredients" do
    field :ancestry, :string
    field :description, :string
    field :name, :string
    field :slug, :string

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
    # We can't insert current user_id value into Ingredient as it's the UUID User.public_id, not the internal primary key id,
    #   and so need to resolve this sort of thing separately.
    |> maybe_resolve_public_user_id()
    |> maybe_update_slug()
    |> validate_required([:name, :slug])
    |> assoc_constraint(:user)
    |> unique_constraint([:name, :user_id])
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:user_id)
  end

  defp maybe_update_slug(%Ecto.Changeset{valid?: true, changes: %{name: name}} = ingredient) do
    put_change(ingredient, :slug, generate_slug(name))
  end
  defp maybe_update_slug(ingredient), do: ingredient

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

  defp generate_slug(name) do
    name
    base_slug = name
                |> String.downcase
                |> String.replace(~r/[^a-z0-9\s-]/, "")
                |> String.replace(~r/(\s|-)+/, "-")

    "#{base_slug}-#{generate_random_suffix()}"
  end

  defp generate_random_suffix(length \\ 6) do
    SecureRandom.urlsafe_base64(length)
  end
end
