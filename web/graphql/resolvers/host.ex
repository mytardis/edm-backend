defmodule EdmBackend.GraphQL.Resolver.Host do
  alias EdmBackend.Repo
  alias EdmBackend.Host

  def list_hosts(client) do
    {:ok, client |> Host.all_hosts}
  end

  def find(%{destination: destination}) do
    {:ok, Repo.get_by(Host, id: destination.host_id)}
  end
end
