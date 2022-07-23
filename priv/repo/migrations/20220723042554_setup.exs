defmodule MTKitchen.Repo.Migrations.Setup do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;", "DROP EXTENSION pg_stat_statements;"
  end
end
