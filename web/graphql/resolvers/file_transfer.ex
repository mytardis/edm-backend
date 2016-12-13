defmodule EdmBackend.GraphQL.Resolver.FileTransfer do
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.FileTransfer

  def list(args, file) do
    {:ok, file |> FileTransfer.get_transfers_for_file}
  end
end
