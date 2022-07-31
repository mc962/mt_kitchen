defmodule MTKitchen.Repo.Migrations.CreateSteps do
  use Ecto.Migration

  def change do
    create table(:steps) do
      add :order, :integer, null: false
      add :instruction, :text, null: false
      add :recipe_id, references(:recipes, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:steps, [:recipe_id])
  end
end
