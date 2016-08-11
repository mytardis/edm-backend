defmodule EdmBackend.Repo.Migrations.Groups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string, size: 50
      add :description, :string, size: 255
      add :parent_id, :integer
      timestamps
    end
    create unique_index(:groups, [:name])
  end
end
