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

    field :basepath, :string, virtual: true
    field :check_method, :string, virtual: true
    field :cron_time, :string, virtual: true

    belongs_to :owner, Client

    has_many :files, File
    has_many :destinations, Destination

    timestamps()
  end

  @allowed ~w(name fstype settings)a
  @required ~w(name fstype)a

  @settings ~w(basepath check_method cron_time)a

  def settings_to_db(source, params) do
    {settings_params, _} = Map.split(params, @settings)
    params = Map.put(params, :settings, Enum.reduce(
      settings_params, Map.get(source.params, :settings, %{}), fn({k, v}, settings) ->
        %{settings | k: v}
      end))
    cast(source, params, [:settings])
  end

  def settings_from_db(source) do
    {defined_settings, _} = (for {key, val} <- source.settings, into: %{}, do:
        {String.to_atom(key), val}) |> Map.split(@settings)
    Map.merge(source, defined_settings)
  end

  def changeset(%Source{} = source, params \\ %{}) do
    source
    |> cast(params, @settings)
    |> settings_to_db(params)
    |> cast(params, @allowed)
    |> cast_assoc(:owner, required: true)
    |> validate_required(@required)
  end

  @doc """
  Returns a list of all sources that belong to the given client
  """
  def all_sources(client) do
    query = from s in Source,
      where: s.owner_id == ^client.id
    Repo.all(query) |> Enum.map(fn(s) -> settings_from_db(s) end)
  end

  @doc """
  Returns the source with the given name belonging to the given client
  """
  def find(client, name) do
    query = from s in Source,
      where: s.owner_id == ^client.id and s.name == ^name,
      preload: :destinations
    case Repo.one(query) do
      nil -> {:error, "Source name #{name} not found"}
      source ->
        {:ok, source |> settings_from_db}
    end
  end

  @doc """
  Gets or creates the source as specified by the source_info map and assigns it
  to the given client
  """
  def get_or_create(client, source_info) do
    case Source.find(client, source_info.name) do
      {:ok, source} ->
        {:ok, source}
      {:error, _} ->
        %Source{owner: client} |> Source.changeset(source_info) |> Repo.insert
    end
  end

  @doc """
  Updates the source with the information provided in the source_info map
  """
  def update(source = %Source{}, source_info) do
    source |> changeset(source_info) |> Repo.update
  end
end
