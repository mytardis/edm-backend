defmodule EdmBackend.Repo.Migrations.AddFileTransfersTable do
  use Ecto.Migration

  def change do
    create table(:file_transfers, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")

      add :transfer_status, :string, size: 20
      add :bytes_transferred, :integer

      add :file_id, references(:files, type: :uuid)
      add :destination_id, references(:destinations, type: :uuid)

      timestamps
    end
  end
end
