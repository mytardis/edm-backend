defmodule EdmBackend.GraphQL.Resolver.Client do
  import Canada, only: [can?: 2]
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.Client

  def list_groups(args, client, viewer) do
    if viewer |> can?(view(client)) do
      {:ok, client |> Client.all_groups |> Relay.Connection.from_list(args)}
    else
      {:ok, []}
    end
  end

  def list(args, viewer) do
    all_clients = for client <- Client |> Repo.all do
      if viewer |> can?(view(client)) do
        client
      end
    end
    {:ok, all_clients |> Relay.Connection.from_list(args)}
  end

  def find(%{id: id}, viewer) do
    case Repo.get(Client, id) do
      nil -> {:error, "Client not found"}
      client ->
        if viewer |> can?(view(client)) do
          {:ok, client}
        else
          {:error, "Unauthorised to view client"}
        end
    end
  end

  def generate_token(client, viewer) do
    if viewer |> can?(impersonate(client)) do
      {:ok, jwt, full_claims} = Guardian.encode_and_sign(client, :access)
      {:ok, jwt}
    else
      {:error, "Unauthorised to impersonate client"}
    end
  end
end
