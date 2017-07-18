defmodule EdmBackend.FileTransfer do
  use EdmBackend.Web, :model
  alias EdmBackend.Repo
  alias EdmBackend.FileTransfer
  alias EdmBackend.File
  alias EdmBackend.Destination
  require Logger

  schema "file_transfers" do
    field :status, :string  # maybe an enum?
    field :bytes_transferred, :integer

    belongs_to :file, File
    belongs_to :destination, Destination

    timestamps()
  end

  @allowed ~w(status bytes_transferred)a
  @required ~w(status)a

  def changeset(model, params \\ %{}) do
    model |> cast(params, @allowed)
          |> cast_assoc(:file, required: true)
          |> cast_assoc(:destination, required: true)
          |> validate_required(@required)
          |> unique_constraint(
              :destination, name: :file_transfers_file_id_destination_id_index)
  end

  @doc """
  Returns a list of all transfers for the given file
  """
  def get_transfers_for_file(file) do
    query = from ft in FileTransfer,
      where: ft.file_id == ^file.id
    Repo.all(query)
  end

  @doc """
  Returns a list of all transfers for the given destination
  """
  def get_transfers_for_destination(destination, status, amount \\ 0) do
    query = from ft in FileTransfer,
      preload: :destination,
      preload: :file,
      where: ft.destination_id == ^destination.id
    query = case status do
              status when is_nil(status) ->
                query
              status ->
                query = query |> where([ft], ft.status == ^status)
            end
    if amount != 0 do
      query = query |> limit(^amount)
    end
    transfers = Repo.all(query)
    Logger.debug("Sending transfers for destination #{inspect(destination)} "
                 <> "#{inspect(transfers)}")
    transfers
  end

  @doc """
  returns eligible transfers and marks them as queued
  """
  def checkout_transfers(destination, amount) do
    transfers = get_transfers_for_destination(destination, "new", amount)
    transfers = Enum.map(transfers, fn(transfer) ->
      {:ok, transfer} = transfer |> changeset(%{status: "queued"})
                                 |> Repo.update
      transfer
    end)
#    {:ok, transfers}
  end

  @doc """
  Updates the file transfer with the information provided in the
  file_transfer_info map
  Disallow editing of cancelled and completed transfers
  """
  def update(%FileTransfer{} = file_transfer, file_transfer_info) do
    if file_transfer.status != "cancelled" and
       file_transfer.status != "complete" do
      file_transfer = file_transfer |> Repo.preload(:file)
                                    |> Repo.preload(:destination)
      file_transfer |> changeset(file_transfer_info) |> Repo.update
    else
      {:ok, file_transfer}
    end
  end

  def cancel_transfer(%FileTransfer{} = ft) do
    ft = ft |> Repo.preload(:file) |> Repo.preload(:destination)
    if ! ft.status == "complete" do
      Logger.debug("Cancelling FileTransfer #{ft.id} with status #{ft.status}")
      changeset(ft, %{status: "cancelled"})
      |> Repo.update
    end
  end

end
