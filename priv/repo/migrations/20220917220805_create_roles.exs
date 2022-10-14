defmodule MTKitchen.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:roles, [:name])

    create table(:user_roles, primary_key: false) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all),
        null: false,
        primary_key: true

      add :role_id, references(:roles, on_delete: :delete_all), null: false, primary_key: true

      timestamps()
    end

    create index(:user_roles, [:user_id, :role_id])
  end
end
