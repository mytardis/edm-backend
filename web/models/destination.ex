defmodule EdmBackend.Destination do
  use EdmBackend.Web, :model
  alias EdmBackend.Destination
  alias EdmBackend.Host
  alias EdmBackend.Source
  alias EdmBackend.FileTransfer
  alias EdmBackend.Repo

  schema "destinations" do
    field :base, :string  # path in destination

    belongs_to :host, Host
    belongs_to :source, Source
    has_many :file_transfers, FileTransfer
    has_many :files, through: [:file_transfers, :file]

    timestamps()
  end

  @allowed ~w(base)a
  @required ~w(base)a

  def changeset(model, params \\ %{}) do
    model |> cast(params, @allowed)
          |> cast_assoc(:host, required: true)
          |> cast_assoc(:source, required: true)
          |> validate_required(@required)
  end

  @doc """
  Returns a list of all destinations for a given source
  """
  def all_destinations(source) do
    query = from d in Destination,
      where: d.source_id == ^source.id
    Repo.all(query)
  end
end
