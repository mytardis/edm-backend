defmodule EdmBackend.GraphQL.Resolver.Destination do
  import Canada, only: [can?: 2]
  alias EdmBackend.Destination
  alias EdmBackend.FileTransfer
  alias EdmBackend.Repo

  def list_destinations(source, viewer) do
    if viewer |> can?(view(source)) do
      {:ok, source |> Destination.all_destinations}
    else
      {:error, "Unauthorised to view destinations for source"}
    end
  end

  def find(%{id: id}) do
    case Repo.get(Destination, id) do
      nil -> {:error, "Destination not found"}
      destination -> {:ok, destination}
    end
  end

  def find(%{id: id}, viewer) do
    case find(%{id: id}) do
      {:ok, destination} ->
        if viewer |> can?(view(destination)) do
          {:ok, destination}
        else
          {:error, "Unauthorised to view destination"}
        end
      {:error, error} -> {:error, error}
    end
  end

  def find(%{file_transfer: file_transfer = %FileTransfer{}}, viewer) do
    destination = file_transfer |> Repo.preload(:destination) |> Map.get(:destination)
    if viewer |> can?(view(destination)) do
      {:ok, destination}
    else
      {:error, "Unauthorised to view destination"}
    end
  end

  def from_global_id(global_id, viewer \\ nil) do
    case Absinthe.Relay.Node.from_global_id(global_id, EdmBackend.GraphQL.Schema) do
      {:ok, %{type: :destination, id: id}} ->
        case viewer do
          nil ->
            find(%{id: id})
          v ->
            find(%{id: id}, v)
        end
      {:ok, %{type: _, id: id}} ->
        {:error, "Invalid ID"}
      {:error, error} -> {:error, error}
    end
  end
end
