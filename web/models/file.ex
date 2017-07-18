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
    #  ctime: 2016-10-26T04:56:40.000Z,  # last modified content or
    # metadata time
    #  birthtime: 2013-06-05T06:40:25.000Z }  # creation time or
    # last modified time (fs dependent)
    field :size, :integer
    field :mode, :integer  # needs to be interpreted platform specifically
    field :atime, Calecto.DateTimeUTC
    field :mtime, Calecto.DateTimeUTC
    field :ctime, Calecto.DateTimeUTC
    field :birthtime, Calecto.DateTimeUTC

    belongs_to :source, Source

    has_many :file_transfers, FileTransfer
    many_to_many :destinations, Destination, join_through: FileTransfer

    timestamps()
  end

  @allowed ~w(filepath size mtime mode atime ctime birthtime)a
  @required ~w(filepath size mtime)a

  def changeset(file, params \\ %{}) do
    file
    |> cast(params, @allowed)
    |> cast_assoc(:source, required: true)
    |> validate_required(@required)
  end

  @doc """
  Creates file transfer records for each destination for a given file
  """
  def add_file_transfers(destinations, file, status \\ "new")

  def add_file_transfers([], _file, _status) do
    # Do nothing
  end

  def add_file_transfers([dest|tail], file, status) do
    # This will fail if the transfer already exists due to db constraints,
    # but silently ignored. This ensures that duplicate transfers will not be
    # created.
    create_file_transfer(file, dest, status)
    add_file_transfers(tail, file, status)
  end

  def create_file_transfer(file, dest, status \\ "new") do
    %FileTransfer{file: file, destination: dest}
    |> FileTransfer.changeset(%{status: status})
    |> Repo.insert
  end

  @doc """
  Updates file transfer records by first adding missing file transfers, then
  removing superfluous ones, leaving completed file transfers as a historical
  record
  """
  def update_file_transfers(destinations, file) do
    file = file |> Repo.preload(:file_transfers)
    add_file_transfers(destinations, file)
    Enum.map(file.file_transfers, fn(ft) ->
      if ! (ft.status == "complete" or
            Enum.any?(destinations, &(&1.id == ft.destination_id))) do
        ft |> Repo.delete!
      end
    end)
  end

  @doc """
  Returns a query to retrieve all files for a source
  """
  def get_file_query(source) do
    from f in File,
      where: f.source_id == ^source.id,
      preload: :file_transfers,
      preload: :source
  end

  @doc """
  Returns a query to retrieve a file with the given path for a given source
  """
  def get_file_by_path(source, %{filepath: filepath}) do
    get_file_query(source) |> where([f], f.filepath == ^filepath) |> Repo.one
  end

  @doc """
  Returns a list of all files for the given source
  """
  def list(source) do
    source |> get_file_query |> Repo.all
  end

  @doc """
  updates details of an existing file
  """
  def update_file(%File{} = file, file_info) do
    file = file |> Repo.preload(:source)
    {:ok, file} = file |> changeset(file_info)
                       |> Repo.update
    {:ok, file}
  end

  @doc """
  create new file
  """
  def create_file(source, file_info) do
    %File{source: source}
    |> File.changeset(file_info)
    |> Repo.insert
  end

  @doc """
  create new file and file_transfers
  """
  def create(source, file_info) do
    {:ok, file} = create_file(source, file_info)
    {:ok, file} = update_transfers(file)
    {:ok, file}
  end

  @doc """
  test for differences between file from db and file_info
  return changes
  """
  def file_changes(file, file_info) do
    # ignore atime
    {_, _file_info} = Map.pop(file_info, :atime)
    keys = Map.keys(_file_info)
    {db_file_info, _} = Map.split(file, keys)
    changes = Enum.reduce(keys, %{}, fn(key, changes) ->
      equal = case Map.get(db_file_info, key) do
                %DateTime{} = db_dt ->
                  DateTime.compare(db_dt, Map.get(file_info, key)) == :eq
                value ->
                  value == Map.get(file_info, key)
              end
      if ! equal do
        changes = Map.put(changes, key, {Map.get(db_file_info, key),
                          Map.get(file_info, key)})
      end
      changes
    end)
    changes
  end

  @doc """
  Cancel all active file transfers
  """
  def cancel_transfers(file) do
    file = file |> Repo.preload(:file_transfers)
    Enum.map(file.file_transfers, &FileTransfer.cancel_transfer(&1))
  end

  @doc """
  Creates or updates a file in a source.

  Check if file exists
   if it does, cancel existing transfers only if file_info changed
   else create file
  In all cases cancel transfers to destinations that have been removed, create
  new file transfers unless they already exist and are not
  cancelled
  """
  def create_or_update(source, file_info) do
    file = case get_file_by_path(source, file_info) do
             %File{} = file ->
               {:ok, file} = File.update(file, file_info)
               file
             _ ->
               {:ok, file} = create(source, file_info)
               file
           end
    {:ok, file}
  end

  # @doc """
  # Updates an existing file
  # """
  # @doc """
  # Updates an existing file from a given source. Returns an error if the file
  # does not exist.
  # """
  # def update(source = %Source{}, file_info) do
  #   case get_file_query(source, file_info) |> Repo.one do
  #     nil ->
  #       {:error, "File does not exist"}
  #     file -> File.update(file, file_info)
  #   end
  # end

  def update(%File{} = file, file_info) do
    file = case file_changes(file, file_info) do
             changes when map_size(changes) > 0 ->
               Logger.debug("File #{inspect(file.filepath)} supposedly changed")
               Logger.debug("Changes: #{inspect(changes)}")
               cancel_transfers(file)
               {:ok, file} = update_file(file, file_info)
               file
             _ ->
               file
           end
    {:ok, file} = update_transfers(file)
    {:ok, file}
  end

  @doc """
  Updates file transfers for a file
  """
  def update_transfers(%File{} = file) do

    file = file |> Repo.preload(:file_transfers)
    existing_ft = file.file_transfers
    existing_destinations = Enum.map(existing_ft, fn(ft) ->
      if ft.status != "cancelled" do
        ft.destination_id
      end
    end)

    file = file |> Repo.preload(:source)
    source = file.source |> Repo.preload(:destinations)
    destination_ids = Enum.map(source.destinations, fn(dest) -> dest.id end)
    Enum.map(existing_ft, fn(ft) ->
      if ! ft.destination in destination_ids do
        FileTransfer.cancel_transfer(ft)
      end
    end)

    Enum.map(source.destinations, fn(dest) ->
      if ! dest.id in existing_destinations do
        create_file_transfer(file, dest)
      end
    end)

    {:ok, file}
  end
end
