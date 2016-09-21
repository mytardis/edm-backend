defmodule EdmBackend.Repo.Migrations.UserCredentials do
  use Ecto.Migration

  def change do
    create table(:user_credentials, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :auth_provider, :string, size: 255
      add :remote_id, :string, size: 255
      add :extra_data, :string, size: 1000
      add :user_id, references(:users, type: :uuid)
      timestamps
    end
    create unique_index(:user_credentials, [:auth_provider, :remote_id])
  end
end
