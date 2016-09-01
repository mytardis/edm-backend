defmodule EdmBackend.Repo.Migrations.GroupMembership do
  use Ecto.Migration

  def change do
    create table(:group_memberships) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :group_id, references(:groups, on_delete: :delete_all)
      timestamps
    end
    create unique_index(:group_memberships, [:user_id, :group_id])
  end
end
