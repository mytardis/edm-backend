defmodule EdmBackend.Repo.Migrations.AddFilesTable do
  use Ecto.Migration

  def change do
    create table(:files, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")

      add :filepath, :text
      add :size, :integer
      add :mode, :integer
      add :atime, :datetime
      add :mtime, :datetime
      add :ctime, :datetime
      add :birthtime, :datetime

      add :source_id, references(:sources, type: :uuid)

      timestamps
    end

    execute """
      ALTER TABLE files
      ADD CONSTRAINT unique_files_per_source UNIQUE (source_id, filepath);
    """
  end
end
