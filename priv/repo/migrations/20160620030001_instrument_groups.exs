defmodule EdmBackend.Repo.Migrations.InstrumentGroups do
  use Ecto.Migration

  def change do
    create table(:instrument_groups, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, size: 255
      add :description, :string, size: 255
      add :configuration_blob, :string, size: 4000
      add :facility_id, references(:facilities, type: :uuid)
      timestamps
    end
    create unique_index(:instrument_groups, [:name, :facility_id])
  end
end
