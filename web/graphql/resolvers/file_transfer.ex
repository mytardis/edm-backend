defmodule EdmBackend.GraphQL.Resolver.FileTransfer do
  import Canada, only: [can?: 2]
  alias EdmBackend.FileTransfer
  alias EdmBackend.Repo

  def list(_args, file, viewer) do
    if viewer |> can?(view(file)) do
      {:ok, file |> FileTransfer.get_transfers_for_file}
    else
      {:error, "Unauthorised to view transfers for file"}
    end
  end

  def find(%{id: id}) do
    case Repo.get(FileTransfer, id) do
      nil -> {:error, "File transfer not found"}
      file_transfer -> {:ok, file_transfer}
    end
  end

  def find(%{id: id}, viewer) do
    case find(%{id: id}) do
      {:ok, file_transfer} ->
        if viewer |> can?(view(file_transfer)) do
          {:ok, file_transfer}
        else
          {:error, "Unauthorised to view file transfer"}
        end
      {:error, error} -> {:error, error}
    end
  end

  def from_global_id(global_id, viewer \\ nil) do
    case Absinthe.Relay.Node.from_global_id(global_id, EdmBackend.GraphQL.Schema) do
      {:ok, %{type: :file_transfer, id: id}} ->
        case viewer do
          nil ->
            find(%{id: id})
          v ->
            find(%{id: id}, v)
        end
      {:ok, %{type: _, id: id}} ->
        {:error, "Invalid ID"}
      {:error, error} -> {:error, error}
    end
  end

  def update(file_transfer, new_file_transfer, viewer) do
    if viewer |> can?(update(file_transfer)) do
      FileTransfer.update(file_transfer, new_file_transfer)
    else
      {:error, "Unauthorised to update file transfer"}
    end
  end
end
