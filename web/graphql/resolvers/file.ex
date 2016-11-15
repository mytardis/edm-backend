defmodule EdmBackend.GraphQL.Resolver.File do
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.File
  alias EdmBackend.Source

  def list(args, client) do
    {:ok, [%{filepath: "blafile"}] |> Relay.Connection.from_list(args)}
  end

  def find(source, filepath) do
    {:ok, %{filepath: filepath}}
  end

  def create(client, source_name, file) do
    require IEx
    IEx.pry
    source = Repo.get_by!(Source, owner_id: client.id, name: source_name)
    new_file = Repo.insert(File.changeset(File, Map.put(file, :source, source)))
    {:ok, %{file: new_file}}
  end
end
