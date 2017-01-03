defmodule EdmBackend.FileTransfer do
  use EdmBackend.Web, :model
  alias EdmBackend.Repo
  alias EdmBackend.FileTransfer
  alias EdmBackend.File
  alias EdmBackend.Destination

  schema "file_transfers" do
    field :status, :string  # maybe an enum?
    field :bytes_transferred, :integer

    belongs_to :file, File
    belongs_to :destination, Destination

    timestamps
  end

  @allowed ~w(status bytes_transferred)a
  @required ~w(status)a

  def changeset(model, params \\ %{}) do
    model |> cast(params, @allowed)
          |> cast_assoc(:file, required: true)
          |> cast_assoc(:destination, required: true)
          |> validate_required(@required)
  end

  def get_transfers_for_file(file) do
    query = from ft in FileTransfer,
      where: ft.file_id == ^file.id
    Repo.all(query)
  end
end
