defmodule EdmBackend.GraphQL.Resolver.UserCredential do
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.UserCredential
  import Ecto.Query

  def list(args, user) do
    query = from credential in UserCredential,
              join: u in assoc(credential, :user),
              where: u.id == ^user.id
    {:ok, query |> Relay.Connection.from_query(&Repo.all/1, args)}
  end

  def find(%{id: id}) do
    case Repo.get(UserCredential, id) do
      nil -> {:error, "User credential id #{id} not found"}
      user_credential -> {:ok, user_credential}
    end
  end

end
