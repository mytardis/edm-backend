defmodule EdmBackend.Repo.Migrations.GroupMembership do
  use Ecto.Migration

  def change do
    create table(:group_memberships, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :client_id, references(:clients, type: :uuid, on_delete: :delete_all)
      add :group_id, references(:groups, type: :uuid, on_delete: :delete_all)
      timestamps()
    end
    create unique_index(:group_memberships, [:client_id, :group_id])
  end
end
