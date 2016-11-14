defmodule EdmBackend.Destination do
  use EdmBackend.Web, :model
  alias EdmBackend.File
  alias EdmBackend.FileTransfer
  alias EdmBackend.Host
  alias EdmBackend.Source

  schema "destinations" do
    field :base, :string  # path in destination

    belongs_to :host, Host
    belongs_to :source, Source
    has_many :file_transfers, FileTransfer
    has_many :files, through: [:file_transfers, :file]

    timestamps
  end
end
