defmodule EdmBackend.GraphQL.Resolver.Destination do
  import Canada, only: [can?: 2]
  alias EdmBackend.Destination
  alias EdmBackend.Repo

  def list_destinations(source, viewer) do
    if viewer |> can?(view(source)) do
      {:ok, source |> Destination.all_destinations}
    else
      {:error, "Unauthorised to view destinations for source"}
    end
  end

  def find(%{id: id}, viewer) do
    case Repo.get(Destination, id) do
      nil -> {:error, "Destination not found"}
      destination ->
        if viewer |> can?(view(destination)) do
          {:ok, destination}
        else
          {:error, "Unauthorised to view destination"}
        end
    end
  end
end
