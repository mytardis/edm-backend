defmodule EdmBackend.GraphQL.Resolver.Group do
  alias Absinthe.Relay
  alias EdmBackend.Group
  alias EdmBackend.Repo

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
