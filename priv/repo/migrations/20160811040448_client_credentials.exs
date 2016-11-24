defmodule EdmBackend.Repo.Migrations.Credentials do
  use Ecto.Migration

  def change do
    create table(:credentials, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :auth_provider, :string, size: 255
      add :remote_id, :string, size: 255
      add :extra_data, :map
      add :client_id, references(:clients, type: :uuid)
      timestamps
    end
    create unique_index(:credentials, [:auth_provider, :remote_id])
  end
end
