defmodule EdmBackend.GraphQL.Resolver.Destination do
  import Canada, only: [can?: 2]
  alias EdmBackend.Destination

  def list_destinations(source, viewer) do
    if viewer |> can?(view(source)) do
      {:ok, source |> Destination.all_destinations}
    else
      {:error, "Unauthorised to view destinations for source"}
    end
  end
end
