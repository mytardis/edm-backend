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

    timestamps()
  end

  @allowed ~w(status bytes_transferred)a
  @required ~w(status)a

  def changeset(model, params \\ %{}) do
    model |> cast(params, @allowed)
          |> cast_assoc(:file, required: true)
          |> cast_assoc(:destination, required: true)
          |> validate_required(@required)
          |> unique_constraint(:destination, name: :file_transfers_file_id_destination_id_index)
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
  def get_transfers_for_destination(destination, status) do
    query = from ft in FileTransfer,
      where: ft.destination_id == ^destination.id
    query = case status do
              status when is_nil(status) ->
                query
              status ->
                query = query |> where([ft], ft.status == ^status)
            end
    Repo.all(query)
  end

  @doc """
  Updates the file transfer with the information provided in the file_transfer_info map
  Disallow editing of cancelled transfers
  """
  def update(%FileTransfer{} = file_transfer, file_transfer_info) do
    if file_transfer_info.status != "cancelled" do
      file_transfer = file_transfer |> Repo.preload(:file) |> Repo.preload(:destination)
      file_transfer |> changeset(file_transfer_info) |> Repo.update
    end
  end

  def cancel_transfer(%FileTransfer{} = ft) do
    ft = ft |> Repo.preload(:file) |> Repo.preload(:destination)
    if ! (ft.status == "complete") do
      changeset(ft, %{status: "cancelled"})
      |> Repo.update
    end
  end

end
