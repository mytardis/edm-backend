defmodule EdmBackend.GraphQL.Resolver.Source do
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.Source
  alias EdmBackend.Client

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
    case Repo.get_by(Source, owner_id: client.id, name: name) do
      nil -> {:error, "Source name #{name} not found"}
      source -> {:ok, source}
    end
  end
end
