defmodule EdmBackend.Repo.Migrations.GroupMembership do
  use Ecto.Migration

  def change do
    create table(:group_memberships, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)
      add :group_id, references(:groups, type: :uuid, on_delete: :delete_all)
      timestamps
    end
    create unique_index(:group_memberships, [:user_id, :group_id])
  end
end
