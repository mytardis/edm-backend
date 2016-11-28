defmodule EdmBackend.Repo.Migrations.AddFilesTable do
  use Ecto.Migration

  def change do
    create table(:files, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")

      add :filepath, :text, null: false
      add :filepath_md5, :string, size: 32, null: false
      add :size, :integer, null: false
      add :mode, :integer
      add :atime, :datetime
      add :mtime, :datetime
      add :ctime, :datetime
      add :birthtime, :datetime

      add :source_id, references(:sources, type: :uuid), null: false

      timestamps
    end

    create unique_index(:files, [:source_id, :filepath_md5])
  end
end
