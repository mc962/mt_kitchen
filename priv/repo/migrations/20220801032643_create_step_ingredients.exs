defmodule MTKitchen.Repo.Migrations.CreateStepIngredients do
  use Ecto.Migration

  def change do
    create table(:step_ingredients) do
      add :amount, :decimal, null: false
      add :unit, :string
      add :condition, :string

      add :step_id, references(:steps, on_delete: :delete_all)
      add :ingredient_id, references(:ingredients, on_delete: :delete_all)

      timestamps()
    end

    create index(:step_ingredients, [:step_id])
    create index(:step_ingredients, [:ingredient_id])
  end
end
