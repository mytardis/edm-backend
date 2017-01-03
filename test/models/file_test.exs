defmodule EdmBackend.FileTest do
  require Logger
  use EdmBackend.ModelCase
  import Ecto.Query, only: [from: 2]
  alias EdmBackend.Repo
  alias EdmBackend.Source
  alias EdmBackend.Destination
  alias EdmBackend.File
  alias EdmBackend.Client
  alias EdmBackend.Host
  alias EdmBackend.Group
  alias EdmBackend.FileTransfer

  setup do
    {:ok, owner} = %Client{} |> Client.changeset(%{
      name: "test client",
    }) |> Repo.insert

    {:ok, group} = %Group{} |> Group.changeset(%{
      name: "test group",
      description: "a test group"
    }) |> Repo.insert

    {:ok, source} = %Source{owner: owner} |> Source.changeset(%{
      name: "test source1",
      fstype: "testfs"
    }) |> Repo.insert

    {:ok, host} = %Host{group: group} |> Host.changeset(%{
      name: "host",
      transfer_method: "sftp",
      settings: %{
        host: "1some.host.edu.au",
        private_key: "AAAAAAAA"
      }
    }) |> Repo.insert

    {:ok, _destination1} = %Destination{
      host: host,
      source: source
    } |> Destination.changeset(%{
      base: "/destination/1/"
    }) |> Repo.insert

    {:ok, _destination2} = %Destination{
      host: host,
      source: source
    } |> Destination.changeset(%{
      base: "/destination/2/"
    }) |> Repo.insert

    {:ok, _destination3} = %Destination{
      host: host,
      source: source
    } |> Destination.changeset(%{
      base: "/destination/3/"
    }) |> Repo.insert

    [source: source]
  end

  test "valid file values", context do
    # Minimal
    file1 = %File{source: context[:source]} |> File.changeset(%{
      filepath: "/somewhere/file1",
      size: 100,
      mtime: DateTime.utc_now()
    })

    # Everything
    file2 = %File{source: context[:source]} |> File.changeset(%{
      filepath: "/somewhere/file1",
      size: 100,
      mtime: DateTime.utc_now(),
      mode: 33188,
      atime: DateTime.utc_now(),
      ctime: DateTime.utc_now(),
      birthtime: DateTime.utc_now()
    })

    assert file1.valid?
    assert file2.valid?
  end

  test "invalid file values", context do
    file1 = %File{} |> File.changeset(%{
      filepath: "/somewhere/file1",
      size: 100,
      mtime: DateTime.utc_now()
    })
    file2 = %File{source: context[:source]} |> File.changeset(%{
      size: 100,
      mtime: DateTime.utc_now()
    })
    file3 = %File{source: context[:source]} |> File.changeset(%{
      filepath: "/somewhere/file1",
      mtime: DateTime.utc_now()
    })
    file4 = %File{source: context[:source]} |> File.changeset(%{
      filepath: "/somewhere/file1",
      size: 100
    })

    refute file1.valid?
    refute file2.valid?
    refute file3.valid?
    refute file4.valid?
  end

  test "create_or_update\\2 creates a file that doesn't exist", context do
    filename = "/a/random/file.txt"

    query = from f in File, where: f.filepath == ^filename, select: count(f.id)

    assert Repo.one(query) == 0

    {:ok, _new_file} = File.create_or_update(context[:source], %{
      filepath: filename,
      size: 100,
      mtime: DateTime.utc_now()
    })

    assert Repo.one(query) == 1
  end

  test "create_or_update\\2 returns a file that already exists", context do
    filename = "/a/random/file1.txt"

    {:ok, new_file} = File.create_or_update(context[:source], %{
      filepath: filename,
      size: 100,
      mtime: DateTime.utc_now()
    })

    {:ok, existing_file} = File.create_or_update(context[:source], %{
      filepath: filename,
      size: 100,
      mtime: DateTime.utc_now()
    })

    assert new_file.id == existing_file.id
  end

  test "create_file_transfers\\3 creates a set of FileTransfer records", context do
    {:ok, file} = %File{source: context[:source]} |> File.changeset(%{
      filepath: "/somewhere/file1",
      size: 100,
      mtime: DateTime.utc_now()
    }) |> Repo.insert

    source = context[:source] |> Repo.preload(:destinations)

    File.add_file_transfers(source.destinations, file)

    query = from ft in FileTransfer,
      where: ft.file_id == ^file.id,
      preload: :destination

    file_transfers = Repo.all(query)
    destination_bases = for ft <- file_transfers, do: ft.destination.base

    assert length(file_transfers) == 3
    assert "/destination/1/" in destination_bases
    assert "/destination/2/" in destination_bases
    assert "/destination/3/" in destination_bases
  end

end
