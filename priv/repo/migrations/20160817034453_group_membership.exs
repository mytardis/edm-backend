defmodule EdmBackend.Repo.Migrations.GroupMembership do
  use Ecto.Migration

  def change do
    create table(:group_memberships) do
      add :user_id, references(:users)
      add :group_id, references(:groups)
      timestamps
    end
    create unique_index(:group_memberships, [:user_id, :group_id])
  end
end
