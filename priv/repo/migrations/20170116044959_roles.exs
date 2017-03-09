defmodule EdmBackend.Repo.Migrations.Roles do
  use Ecto.Migration

  def change do
    create table(:roles, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :name, :string, size: 20
      add :description, :string, size: 255
      add :type, :string, size: 20

      add :source_group_id, references(:groups, type: :uuid, on_delete: :delete_all)
      add :target_group_id, references(:groups, type: :uuid, on_delete: :delete_all)

      timestamps()
    end
    create unique_index(:roles, [:type, :source_group_id, :target_group_id])
  end
end
