defmodule EdmBackend.File do
  use EdmBackend.Web, :model
  alias EdmBackend.Destination
  alias EdmBackend.File
  alias EdmBackend.FileTransfer
  alias EdmBackend.Repo
  alias EdmBackend.Source

  schema "files" do
    field :filepath, :string  # relative path
    field :filepath_md5, :string

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

  @allowed ~w(filepath size mode atime mtime ctime birthtime source_id)a
  @required ~w(filepath filepath_md5 size mtime source_id)a

  def compute_filepath_hash(file) do
    require IEx
    # IEx.pry
    case Map.get(file, :filepath_md5) do
      nil ->
        md5 = Base.encode16(:erlang.md5(file.changes.filepath), case: :lower)
        %{file | changes: Map.put(file.changes, :filepath_md5, md5)}
      _ ->
        file
    end
  end

  def changeset(file, params \\ %{}) do
    file
    |> cast(params, @allowed)
    |> compute_filepath_hash
    |> validate_required(@required)
  end

  def get_or_create(source, file_info) do
    # try to find file
    query = from f in File,
      where: f.source_id == ^(source.id) and
        f.filepath == ^(file_info.filepath),
      select: f
    require IEx
    #IEx.pry
    case Repo.one(query) do
      nil ->
        # create new file and prompt upload
        file_info = Map.put(file_info, :source_id, source.id)
        {:ok, new_file} = Repo.insert(File.changeset(%File{}, file_info))
        Enum.map(source.destinations, fn(dest) ->
          Repo.insert(
              FileTransfer.changeset(%FileTransfer{}, %{
                transfer_status: "new",
                file_id: new_file.id,
                destination_id: dest.id,
              }))
          end)
        {:ok, new_file}
      file ->
        # if found, devise action
        file = Repo.preload(file, :file_transfers)
        # case file.file_transfer do
        #   nil ->
        case file.file_transfers do
          [] ->
            Enum.map(source.destinations, fn(dest) ->
              Repo.insert(
                  FileTransfer.changeset(%FileTransfer{}, %{
                    transfer_status: "new",
                    file_id: file.id,
                    destination_id: dest.id,
                  }))
              end)
            # new transfers
            {:ok, file}
          transfers ->
            # existing transfers mean no action
            {:ok, file}
        end
      {:error, error} ->
        {:error, error}
    end
  end
end
