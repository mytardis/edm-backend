defmodule EdmBackend.GraphQL.Resolver.Destination do
  alias EdmBackend.Destination

  def list_destinations(source) do
    {:ok, source |> Destination.all_destinations}
  end
end
