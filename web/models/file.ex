defmodule EdmBackend.File do
  use EdmBackend.Web, :model
  require Logger
  alias EdmBackend.Destination
  alias EdmBackend.File
  alias EdmBackend.FileTransfer
  alias EdmBackend.Repo
  alias EdmBackend.Source

  schema "files" do
    field :filepath, :string  # relative path
    # field :filepath_md5, :string

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
    field :atime, Calecto.DateTimeUTC
    field :mtime, Calecto.DateTimeUTC
    field :ctime, Calecto.DateTimeUTC
    field :birthtime, Calecto.DateTimeUTC

    belongs_to :source, Source

    has_many :file_transfers, FileTransfer
    many_to_many :destinations, Destination, join_through: FileTransfer

    timestamps
  end

  @allowed ~w(filepath size mtime mode atime ctime birthtime)a
  @required ~w(filepath size mtime)a

  def changeset(file, params \\ %{}) do
    file
    |> cast(params, @allowed)
    |> cast_assoc(:source, required: true)
    |> validate_required(@required)
  end

  def create_file_transfers(destinations, file, status \\ "new")

  def create_file_transfers([], file, status) do
    # Do nothing
  end

  def create_file_transfers([dest|tail], file, status) do
    %FileTransfer{file: file, destination: dest}
      |> FileTransfer.changeset(%{status: status})
      |> Repo.insert
    create_file_transfers(tail, file, status)
  end

  def get_or_create(source, file_info) do
    # try to find file
    query = from f in File,
      where: f.source_id == ^source.id,
      where: f.filepath == ^file_info.filepath,
      preload: :file_transfers

    source = source |> Repo.preload(:destinations)

    case Repo.one(query) do
      nil ->
        # create new file and prompt upload
        {:ok, new_file} = %File{source: source}
          |> File.changeset(file_info)
          |> Repo.insert

        create_file_transfers(source.destinations, new_file)
        {:ok, new_file}

      {:error, error} ->
        {:error, error}

      file ->
        case file.file_transfers do
          [] ->
            create_file_transfers(source.destinations, file)
            # new transfers
            {:ok, file}
          _transfers ->
            # existing transfers mean no action
            {:ok, file}
        end
    end
  end
end
