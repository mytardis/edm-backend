defmodule EdmBackend.GraphQL.Resolver.Host do
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.Host
  alias EdmBackend.Client

  def list_hosts(client) do
    {:ok, client |> Host.all_hosts}
  end

  def find(%{destination: destination}) do
    {:ok, Repo.get_by(Host, id: destination.host_id)}
  end
end
