defmodule EdmBackend.GraphQL.Resolver.Client do
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.Client
  alias EdmBackend.InstrumentGroup
  import Ecto.Query

  def list(args, instrument_group) do
    query = from client in Client,
              join: i_group in assoc(client, :instrument_group),
              where: i_group.id == ^instrument_group.id
    {:ok, query |> Relay.Connection.from_query(&Repo.all/1, args)}
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
