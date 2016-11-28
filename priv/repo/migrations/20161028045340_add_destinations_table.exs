defmodule EdmBackend.Repo.Migrations.AddDestinationsTable do
  use Ecto.Migration

  def change do
    create table(:destinations, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")

      add :base, :text

      add :host_id, references(:hosts, type: :uuid)
      add :source_id, references(:sources, type: :uuid)

      timestamps
    end
  end
end
