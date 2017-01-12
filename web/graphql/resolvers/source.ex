defmodule EdmBackend.GraphQL.Resolver.Source do
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.Source

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
    Source.find(client, name)
  end

  def get_or_create(client, source_info) do
    Source.get_or_create(client, source_info)
  end
end
