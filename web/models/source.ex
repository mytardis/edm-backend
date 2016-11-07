defmodule EdmBackend.Source do
  use EdmBackend.Web, :model
  alias EdmBackend.Destination
  alias EdmBackend.File
  alias EdmBackend.Group

  schema "source" do
    field :name, :string
    field :fstype, :string  # POSIX, NTFS

    belongs_to :owner, Group

    has_many :files, File
    has_many :destinations, Destination

    timestamps
  end
end
