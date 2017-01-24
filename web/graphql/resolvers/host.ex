defmodule EdmBackend.GraphQL.Resolver.Host do
  import Canada, only: [can?: 2]
  alias EdmBackend.Repo
  alias EdmBackend.Host
  alias EdmBackend.Destination

  def list_hosts(client, viewer) do
    all_hosts = for host <- client |> Host.all_hosts do
      if viewer |> can?(view(host)) do
        host
      end
    end
    {:ok, all_hosts}
  end

  def find(%{id: id}, viewer) do
    case Repo.get(Host, id) do
      nil ->
        {:error, "Host not found"}
      host ->
        if viewer |> can?(view(host)) do
          {:ok, host}
        else
          {:error, "Unauthorised to view host"}
        end
    end
  end

  def find(%{destination: destination = %Destination{}}, viewer) do
    host = destination |> Repo.preload(:host) |> Map.get(:host)
    if viewer |> can?(view(host)) do
      {:ok, host}
    else
      {:error, "Unauthorised to view host"}
    end
  end
end
