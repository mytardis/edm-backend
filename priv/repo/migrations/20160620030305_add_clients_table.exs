defmodule EdmBackend.Repo.Migrations.AddClientsTable do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :uuid, :string, size: 36
      add :ip_address, :string, size: 46
      add :nickname, :string
      add :instrument_group_id, references(:instrument_groups)
      timestamps
    end
    create unique_index(:clients, [:uuid])
  end
end
