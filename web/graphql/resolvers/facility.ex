defmodule EdmBackend.GraphQL.Resolver.Facility do
  alias EdmBackend.Repo
  alias EdmBackend.Client
  alias EdmBackend.InstrumentGroup
  alias EdmBackend.Facility

  def find(%InstrumentGroup{} = instrument_group) do
    %{id: id} = instrument_group
    case instrument_group |> Repo.preload(:facility) |> Map.get(:facility) do
      nil -> {:error, "Facility for instrument group id #{id} not found"}
      facility -> {:ok, facility}
    end
  end

  def find(%Client{} = client) do
    %{id: id} = client
    case client |> Repo.preload(:facility) |> Map.get(:facility) do
      nil -> {:error, "Facility for client id #{id} not found"}
      client -> {:ok, client}
    end
  end

  def find(%{id: id}) do
    case Repo.get(Facility, id) do
      nil -> {:error, "Facility id #{id} not found"}
      facility -> {:ok, facility}
    end
  end
end
