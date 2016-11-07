defmodule EdmBackend.FileTransfer do
  use EdmBackend.Web, :model

  alias EdmBackend.Destination
  alias EdmBackend.File

  schema "file_transfers" do
    field :transfer_status, :string  # maybe an enum?
    field :bytes_transferred, :integer

    belongs_to :file, File
    belongs_to :destination, Destination

    timestamps
  end
end
