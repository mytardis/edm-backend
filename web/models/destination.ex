defmodule EdmBackend.Destination do
  use EdmBackend.Web, :model
  alias EdmBackend.Endpoint
  alias EdmBackend.File
  alias EdmBackend.FileTransfer
  alias EdmBackend.Source

  schema "destinations" do
    field :base, :string

    belongs_to :endpoint, Endpoint
    belongs_to :source, Source
    has_many :file_transfers, FileTransfer
    has_many :files, through: [:file_transfers, :file]

    timestamps
  end
end
