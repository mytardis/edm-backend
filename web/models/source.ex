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

    belongs_to :owner, Client

    has_many :files, File
    has_many :destinations, Destination

    timestamps
  end

  def all_sources(client) do
    query = from s in Source,
      join: c in Client,
      where: s.owner_id == c.id,
      select: s
    Repo.all(query)
  end
end
