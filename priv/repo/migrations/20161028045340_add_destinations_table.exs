defmodule EdmBackend.Repo.Migrations.AddDestinationsTable do
  use Ecto.Migration

  def change do
    create table(:destinations, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :base, :text

      add :group_id, references(:destinations, type: :uuid)
      add :host_id, references(:hosts, type: :uuid)
      add :source_id, references(:sources, type: :uuid)

      timestamps
    end
  end
end
