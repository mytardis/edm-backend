defmodule EdmBackend.Repo.Migrations.AddSourcesTable do
  use Ecto.Migration

  def change do
    create table(:sources, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :name, :string, size: 255
      add :fstype, :string, size: 20
      add :settings, :map

      add :owner_id, references(:clients, type: :uuid)

      timestamps
    end

    create unique_index(:sources, [:owner_id, :name])
  end
end
