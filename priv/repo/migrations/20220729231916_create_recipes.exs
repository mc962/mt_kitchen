defmodule MTKitchen.Repo.Migrations.CreateRecipes do
  use Ecto.Migration

  def change do
    create table(:recipes) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text
      add :publicly_accessible, :boolean, default: false, null: false

      add :user_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    create index(:recipes, [:user_id])
    create unique_index(:recipes, [:slug])
    create unique_index(:recipes, [:name, :user_id])
  end
end
