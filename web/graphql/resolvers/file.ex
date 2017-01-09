defmodule EdmBackend.GraphQL.Resolver.File do
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.File
  alias EdmBackend.Source

  def list(args, client) do
    {:ok, [%{filepath: "blafile"}] |> Relay.Connection.from_list(args)}
  end

  def find(%{id: id}) do
    case Repo.get(File, id) do
      nil -> {:error, "File id #{id} not found"}
      file -> {:ok, file}
    end
  end

  def find(source, filepath) do
    {:ok, %{filepath: filepath}}
  end

  def create_or_update(source, file) do
    File.create_or_update(source, file)
  end

  def update(source, file) do
    File.update(source, file)
  end

end
