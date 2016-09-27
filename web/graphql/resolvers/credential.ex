defmodule EdmBackend.GraphQL.Resolver.Credential do
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.Credential
  import Ecto.Query

  def list(args, client) do
    query = from credential in Credential,
              join: u in assoc(credential, :client),
              where: u.id == ^client.id
    {:ok, query |> Relay.Connection.from_query(&Repo.all/1, args)}
  end

  def find(%{id: id}) do
    case Repo.get(Credential, id) do
      nil -> {:error, "Client credential id #{id} not found"}
      credential -> {:ok, credential}
    end
  end

end
