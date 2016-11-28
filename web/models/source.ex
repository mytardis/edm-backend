defmodule EdmBackend.Source do
  use EdmBackend.Web, :model
  alias EdmBackend.Destination
  alias EdmBackend.File
  alias EdmBackend.Client
  alias EdmBackend.Repo
  alias EdmBackend.Source

  schema "sources" do
    field :name, :string  # basepath
    field :fstype, :string  # POSIX, NTFS
    field :settings, :map

    belongs_to :owner, Client

    has_many :files, File
    has_many :destinations, Destination

    timestamps
  end

  @allowed ~w(name fstype settings owner_id)a
  @required ~w(name fstype owner_id)a

  def changeset(source, params \\ %{}) do
    source
    |> cast(params, @allowed)
    |> validate_required(@required)
  end

  def all_sources(client) do
    query = from s in Source,
      join: c in Client,
      where: s.owner_id == c.id,
      select: s
    Repo.all(query)
  end

  def find(client, name) do
    query = from s in Source,
      where: s.owner_id == ^(client.id) and s.name == ^(name),
      preload: :destinations,
      select: s
    case Repo.one(query) do
      nil -> {:error, "Source name #{name} not found"}
      source ->
        Repo.preload(source, :destinations)
        {:ok, source}
    end
  end

  def get_or_create(client, source_info) do
    case Source.find(client, source_info.name) do
      {:ok, source} ->
        {:ok, source}
      {:error, _} ->
        source_info = Map.put(source_info, :owner_id, client.id)
        Repo.insert(Source.changeset(%Source{}, source_info))
    end
  end
end
