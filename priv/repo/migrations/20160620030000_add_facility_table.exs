defmodule EdmBackend.Repo.Migrations.AddFacilityTable do
  use Ecto.Migration

  def change do
    create table(:facilities, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      timestamps
    end
    create unique_index(:facilities, [:name])
  end
end
