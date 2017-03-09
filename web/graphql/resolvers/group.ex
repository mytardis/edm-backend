defmodule EdmBackend.GraphQL.Resolver.Group do
  import Canada, only: [can?: 2]
  alias Absinthe.Relay
  alias EdmBackend.Client
  alias EdmBackend.Repo

  def list_members(args, group, viewer) do
    all_clients = for client <- group |> Client.members do
      if viewer |> can?(view(client)) do
        client
      end
    end
    {:ok, all_clients |> Relay.Connection.from_list(args)}
  end

  def list(args, viewer) do
    all_groups = for group <- Group |> Repo.all do
      if viewer |> can?(view(group)) do
        group
      end
    end
    {:ok, all_groups |> Relay.Connection.from_list(args)}
  end

  def find(%{id: id}) do
    case Repo.get(Group, id) do
      nil -> {:error, "Group not found"}
      group -> {:ok, group}
    end
  end

  def find(%{id: id}, viewer) do
    case find(%{id: id}) do
      {:ok, group} ->
        if viewer |> can?(view(group)) do
          {:ok, group}
        else
          {:error, "Unauthorised to view group"}
        end
      {:error, error} -> {:error, error}
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
      {:ok, %{type: _, id: id}} ->
        {:error, "Invalid ID"}
      {:error, error} -> {:error, error}
    end
  end

end
