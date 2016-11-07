defmodule EdmBackend.Repo.Migrations.AddEndpointsTable do
  use Ecto.Migration

  def change do
    create table(:endpoints, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :name, :string, size: 255
      add :transfer_method, :string, size: 30
      add :settings, :map

      timestamps
    end
  end
end
