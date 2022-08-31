defmodule MTKitchen.Repo.Migrations.AddImageUrlsToResources do
  use Ecto.Migration

  def change do
    alter table(:recipes) do
      add :primary_picture, :string
    end

    alter table(:ingredients) do
      add :primary_picture, :string
    end
  end
end
