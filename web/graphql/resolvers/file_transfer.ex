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

  def find(%{id: id}, viewer) do
    case Repo.get(FileTransfer, id) do
      nil -> {:error, "File transfer not found"}
      file_transfer ->
        if viewer |> can?(view(file_transfer)) do
          {:ok, file_transfer}
        else
          {:error, "Unauthorised to view file transfer"}
        end
    end
  end
end
