defmodule EdmBackend.Repo.Migrations.Clients do
  use Ecto.Migration

  def change do
    create table(:clients, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :name, :string, size: 255
      add :attributes, :map
      timestamps
    end
  end
end
