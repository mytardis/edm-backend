defmodule EdmBackend.GraphQL.Resolver.User do
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.User

  def list_groups_flat(args, user) do
    {:ok, user |> User.all_groups_flat |> Relay.Connection.from_list(args)}
  end

  def list_groups(args, user) do
    {:ok, user |> User.all_groups |> Relay.Connection.from_list(args)}
  end

  def list(args) do
    {:ok, User |> Relay.Connection.from_query(&Repo.all/1, args)}
  end

  def find(%{id: id}) do
    case Repo.get(User, id) do
      nil -> {:error, "User id #{id} not found"}
      user -> {:ok, user}
    end
  end
end
