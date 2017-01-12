defmodule EdmBackend.GraphQL.Resolver.FileTransfer do
  alias EdmBackend.FileTransfer

  def list(_args, file) do
    {:ok, file |> FileTransfer.get_transfers_for_file}
  end
end
