defmodule EdmBackend.GraphQL.Resolver.Host do
  import Canada, only: [can?: 2]
  alias EdmBackend.Repo
  alias EdmBackend.Host
  alias EdmBackend.Destination
  require Logger

  def list(client, viewer) do
    all_hosts = for host <- client |> Host.all_hosts do
      if viewer |> can?(view(host)) do
        host
      end
    end
    {:ok, all_hosts}
  end

  def find(%{id: id}) do
    case Repo.get(Host, id) do
      nil -> {:error, "Host not found"}
      host -> {:ok, host}
    end
  end

  def find(%{id: id}, viewer) do
    case find(%{id: id}) do
      {:ok, host} ->
        if viewer |> can?(view(host)) do
          {:ok, host}
        else
          {:error, "Unauthorised to view host"}
        end
      {:error, error} -> {:error, error}
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

  def from_global_id(global_id, viewer \\ nil) do
    case Absinthe.Relay.Node.from_global_id(global_id, EdmBackend.GraphQL.Schema) do
      {:ok, %{type: :group, id: id}} ->
        case viewer do
          nil ->
            find(%{id: id})
          v ->
            find(%{id: id}, v)
        end
      {:ok, %{type: _, id: _id}} ->
        {:error, "Invalid ID"}
      {:error, error} -> {:error, error}
    end
  end
end
