defmodule EdmBackend.GraphQL.Resolver.Source do
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.Source
  alias EdmBackend.Client
  import Ecto.Query

  def list_sources(client) do
    {:ok, client |> Source.all_sources}
  end

  def list(args) do
    {:ok, Source |> Relay.Connection.from_query(&Repo.all/1, args)}
  end

  def find(%{id: id}) do
    case Repo.get(Source, id) do
      nil -> {:error, "Source id #{id} not found"}
      client -> {:ok, client}
    end
  end

  def find(client, name) do
    query = from s in Source,
      where: s.owner_id == ^(client.id) and s.name == ^(name),
      preload: :destinations,
      select: s
    case Repo.one(query) do
      nil -> {:error, "Source name #{name} not found"}
      source ->
        Repo.preload(source, :destinations)
        {:ok, source}
    end
  end
end
