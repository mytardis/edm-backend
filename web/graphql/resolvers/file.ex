defmodule EdmBackend.GraphQL.Resolver.File do
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.File

  def list(args, source) do
    {:ok, source |> File.list |> Relay.Connection.from_query(args)}
  end

  def find(%{id: id}) do
    case Repo.get(File, id) do
      nil -> {:error, "File id #{id} not found"}
      file -> {:ok, file}
    end
  end

  def find(source, filepath) do
    query = source |> File.get_file_query(%{filepath: filepath})
    case Repo.one(query) do
      nil -> {:error, "File #{filepath} not found"}
      file -> {:ok, file}
    end
  end

  def create_or_update(source, file) do
    File.create_or_update(source, file)
  end

  def update(source, file) do
    File.update(source, file)
  end

end
