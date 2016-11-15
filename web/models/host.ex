defmodule EdmBackend.Host do
  use EdmBackend.Web, :model
  alias EdmBackend.Repo
  alias EdmBackend.Destination
  alias EdmBackend.Source
  alias EdmBackend.Host
  alias EdmBackend.Client

  schema "hosts" do
    field :name, :string
    field :transfer_method, :string
    field :settings, :map

    has_many :destinations, Destination

    timestamps
  end

  def all_hosts(client) do
    query = from h in Host,
      join: d in Destination,
      join: s in Source,
      join: c in Client,
      where: h.id == d.host_id and d.source_id == s.id and s.owner_id == c.id,
      select: h
    Repo.all(query)
  end
end
