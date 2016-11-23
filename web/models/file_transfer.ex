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

  @allowed ~w(transfer_status bytes_transferred file_id destination_id)a
  @required ~w(transfer_status file_id destination_id)a

  def changeset(model, params \\ %{}) do
    model |> cast(params, @allowed)
          |> validate_required(@required)
  end
end
