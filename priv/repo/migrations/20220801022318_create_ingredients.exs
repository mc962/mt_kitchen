defmodule MTKitchen.Repo.Migrations.CreateIngredients do
  use Ecto.Migration

  def change do
    create table(:ingredients) do
      add :name, :string, null: false
      add :slug, :string
      add :description, :text
      add :ancestry, :string

      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:ingredients, ["ancestry text_pattern_ops"], name: :recipes_ancestry_index)
    create unique_index(:ingredients, [:name, :user_id])
    create unique_index(:ingredients, [:slug])
    create index(:ingredients, [:user_id])
  end
end
