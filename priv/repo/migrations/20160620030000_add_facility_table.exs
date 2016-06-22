defmodule EdmBackend.Repo.Migrations.AddFacilityTable do
  use Ecto.Migration

  def change do
    create table(:facilities) do
      add :name, :string
      timestamps
    end
    create unique_index(:facilities, [:name])
  end
end
