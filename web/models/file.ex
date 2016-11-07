defmodule EdmBackend.File do
  use EdmBackend.Web, :model
  alias EdmBackend.Destination
  alias EdmBackend.FileTransfer
  alias EdmBackend.Source

  schema "file" do
    field :filepath, :string  # relative path

    # file stats
    # node stat output, annotated
    # { dev: 16777220,  # device number (disk/partition)
    #  mode: 33188,     # file permissions in decimal (e.g. 33188 -> 100644)
    #  nlink: 1,        # number of hard links to file
    #  uid: 501,        # owner uid
    #  gid: 0,          # group id
    #  rdev: 0,         # ?
    #  blksize: 4096,   # block size
    #  ino: 23520143,   # inode
    #  size: 78,        # file size
    #  blocks: 8,       # number of blocks
    #  atime: 2016-10-26T04:56:40.000Z,  # last accessed time
    #  mtime: 2013-06-05T06:40:25.000Z,  # last modified content time
    #  ctime: 2016-10-26T04:56:40.000Z,  # last modified content or metadata time
    #  birthtime: 2013-06-05T06:40:25.000Z }  # creation time or last modified time (fs dependent)
    field :size, :integer
    field :mode, :integer  # needs to be interpreted platform specifically
    field :atime, Ecto.DateTime
    field :mtime, Ecto.DateTime
    field :ctime, Ecto.DateTime
    field :birthtime, Ecto.DateTime

    belongs_to :source, Source

    has_many :file_transfers, FileTransfer
    many_to_many :destinations, Destination, join_through: FileTransfer

    timestamps
  end

  @required ~w(filepath size mtime)a

end
