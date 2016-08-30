defmodule EdmBackend.GraphQL.Resolver.InstrumentGroup do
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.InstrumentGroup
  alias EdmBackend.Facility
  import Ecto.Query
  import Logger

  def list(args, facility) do
    query = from instrument_group in InstrumentGroup,
              join: f in assoc(instrument_group, :facility),
              where: f.id == ^facility.id
    {:ok, query |> Relay.Connection.from_query(&Repo.all/1, args)}
  end

  def list(args) do
    {:ok, InstrumentGroup |> Relay.Connection.from_query(&Repo.all/1, args)}
  end

  def find(%{id: id}) do
    case Repo.get(InstrumentGroup, id) do
      nil -> {:error, "Instrumeng group id #{id} not found"}
      instrument_group -> {:ok, instrument_group}
    end
  end
end
