defmodule EdmBackend.GraphQL.Resolver.File do
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.File

  def list(args, client) do
    {:ok, [%{filepath: "blafile"}] |> Relay.Connection.from_list(args)}
  end

  def find(source, filepath) do
    {:ok, %{filepath: filepath}}
  end

  def create() do
    {:ok, :created}
  end
end
