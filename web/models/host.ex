defmodule EdmBackend.Host do
  use EdmBackend.Web, :model
  alias EdmBackend.Repo
  alias EdmBackend.Destination
  alias EdmBackend.Source
  alias EdmBackend.Host
  alias EdmBackend.Group

  schema "hosts" do
    field :name, :string
    field :transfer_method, :string
    field :settings, :map

    belongs_to :group, Group

    has_many :destinations, Destination

    timestamps()
  end

  @allowed ~w(name transfer_method settings)a
  @required ~w(name transfer_method settings)a

  def changeset(model, params \\ %{}) do
    model |> cast(params, @allowed)
          |> cast_assoc(:group, required: true)
          |> validate_required(@required)
  end

  @doc """
  Returns a list of all hosts for a given client
  """
  def all_hosts(client) do
    query = from h in Host,
      join: d in Destination,
      join: s in Source,
      where: h.id == d.host_id,
      where: d.source_id == s.id,
      where: s.owner_id == ^client.id,
      select: h
    Repo.all(query)
  end
end
