defmodule EdmBackend.Repo.Migrations.Users do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, size: 255
      add :email, :string, size: 255
      timestamps
    end
    create unique_index(:users, [:email])
  end
end
