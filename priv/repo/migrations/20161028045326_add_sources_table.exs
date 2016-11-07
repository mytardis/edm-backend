defmodule EdmBackend.Repo.Migrations.AddSourcesTable do
  use Ecto.Migration

  def change do
    create table(:sources, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, size: 255
      add :fstype, :string, size: 20

      add :owner_id, references(:groups, type: :uuid)

      timestamps
    end
  end
end
