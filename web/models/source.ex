defmodule EdmBackend.Source do
  use EdmBackend.Web, :model
  alias EdmBackend.Destination
  alias EdmBackend.File
  alias EdmBackend.Client

  schema "source" do
    field :name, :string  # basepath
    field :fstype, :string  # POSIX, NTFS

    belongs_to :owner, Client

    has_many :files, File
    has_many :destinations, Destination

    timestamps
  end
end
