defmodule EdmBackend.Repo.Migrations.AddClientsTable do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :uuid, :string, size: 36
      add :ip_address, :string, size: 46
      add :nickname, :string
      add :facility_id, references(:facilities)
      timestamps
    end
    create unique_index(:clients, [:uuid])
  end
end
