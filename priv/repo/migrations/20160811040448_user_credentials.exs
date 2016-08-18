defmodule EdmBackend.Repo.Migrations.UserCredentials do
  use Ecto.Migration

  def change do
    create table(:user_credentials) do
      add :auth_provider, :string, size: 255
      add :remote_id, :string, size: 255
      add :extra_data, :string, size: 1000
      add :user_id, references(:users)
      timestamps
    end
    create unique_index(:user_credentials, [:auth_provider, :remote_id])
  end
end
