defmodule EdmBackend.GraphQL.Resolver.Client do
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.Client

  def list_groups_flat(args, client) do
    {:ok, client |> Client.all_groups_flat |> Relay.Connection.from_list(args)}
  end

  def list_groups(args, client) do
    {:ok, client |> Client.all_groups |> Relay.Connection.from_list(args)}
  end

  def list(args) do
    {:ok, Client |> Relay.Connection.from_query(&Repo.all/1, args)}
  end

  def find(%{id: id}) do
    case Repo.get(Client, id) do
      nil -> {:error, "Client id #{id} not found"}
      client -> {:ok, client}
    end
  end
end
