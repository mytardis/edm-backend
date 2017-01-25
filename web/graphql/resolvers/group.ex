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

  def find(%{id: id}, viewer) do
    case Repo.get(Group, id) do
      nil -> {:error, "Group not found"}
      group ->
        if viewer |> can?(view(group)) do
          {:ok, group}
        else
          {:error, "Unauthorised to view group"}
        end
    end
  end

end
