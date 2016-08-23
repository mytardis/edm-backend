defmodule EdmBackend.Repo.Migrations.Groups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string, size: 50
      add :description, :string, size: 255
      add :parent_id, references(:groups)
      timestamps
    end
    create unique_index(:groups, [:name, :parent_id], where: "parent_id IS NOT NULL", name: "groups_unique_null_parent_id")
    create unique_index(:groups, [:name], where: "parent_id IS NULL", name: "groups_unique_not_null_parent_id")
  end
end
