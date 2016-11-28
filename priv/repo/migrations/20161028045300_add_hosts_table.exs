defmodule EdmBackend.Repo.Migrations.AddHostsTable do
  use Ecto.Migration

  def change do
    create table(:hosts, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")

      add :name, :string, size: 255
      add :transfer_method, :string, size: 30
      add :settings, :map

      add :group_id, references(:groups, type: :uuid)

      timestamps
    end

    create unique_index(:hosts, [:group_id, :name])

  end
end
