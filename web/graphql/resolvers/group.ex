defmodule EdmBackend.GraphQL.Resolver.Group do
  alias Absinthe.Relay
  alias EdmBackend.Group
  alias EdmBackend.Repo

  def get_parent(group) do
    {:ok,
      group
        |> Group.load_parents
        |> Map.get(:parent)
    }
  end

  def list_children(args, group) do
    {:ok,
      group
        |> Group.load_children
        |> Map.get(:children)
        |> Relay.Connection.from_list(args)
    }
  end

  def list_members(args, group) do
    {:ok,
      group |> Group.members
            |> Relay.Connection.from_list(args)
    }
  end

  def list(args) do
    {:ok, Group |> Relay.Connection.from_query(&Repo.all/1, args)}
  end

  def find(%{id: id}) do
    case Repo.get(Group, id) do
      nil -> {:error, "Group id #{id} not found"}
      group -> {:ok, group}
    end
  end

end
