defmodule EdmBackend.Repo.Migrations.Groups do
  use Ecto.Migration

  def change do
    create table(:groups, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, size: 50
      add :description, :string, size: 255
      timestamps()
    end

    create unique_index(:groups, [:name])
  end
end
