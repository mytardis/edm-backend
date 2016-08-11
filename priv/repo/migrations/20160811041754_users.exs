defmodule EdmBackend.Repo.Migrations.Users do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, size: 255
      add :email, :string, size: 255
      timestamps
    end
    create unique_index(:users, [:name, :email])
  end
end
