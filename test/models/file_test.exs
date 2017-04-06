defmodule EdmBackend.FileTest do
  @moduledoc """
  Testing the File model and related functions

  create_or_update_file tests should cover these cases:
  file exists                      | file is new
  file_info changed | file stayed the same      | file info is new
  3 file cases
  ft exist | ft cancelled | new ft | removed ft | new fts
  5 file transfer cases

  """
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

    {:ok, source1} = %Source{owner: owner} |> Source.changeset(%{
      name: "test source1",
      fstype: "testfs"
    }) |> Repo.insert

    {:ok, source2} = %Source{owner: owner} |> Source.changeset(%{
      name: "test source2",
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
      source: source1
    } |> Destination.changeset(%{
      base: "/destination/1/"
    }) |> Repo.insert

    {:ok, _destination2} = %Destination{
      host: host,
      source: source1
    } |> Destination.changeset(%{
      base: "/destination/2/"
    }) |> Repo.insert

    {:ok, _destination3} = %Destination{
      host: host,
      source: source1
    } |> Destination.changeset(%{
      base: "/destination/3/"
    }) |> Repo.insert

    [source1: source1, source2: source2]
  end

  test "file belongs to same group as client", context do
    {:ok, new_file} = File.create_or_update(context[:source1], %{
      filepath: "test/file",
      size: 100,
      mtime: DateTime.utc_now()
    })
    [group] = Group.get_groups_for(new_file)
    assert group.name == "test client"
  end

  test "valid file values", context do
    # Minimal
    file1 = %File{source: context[:source1]} |> File.changeset(%{
      filepath: "/somewhere/file1",
      size: 100,
      mtime: DateTime.utc_now()
    })

    # Everything
    file2 = %File{source: context[:source1]} |> File.changeset(%{
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

  test "files listed by source", context do
    {:ok, file1} = %File{source: context[:source1]} |> File.changeset(%{
      filepath: "/somewhere/file1",
      size: 100,
      mtime: DateTime.utc_now()
    }) |> Repo.insert

    {:ok, file2} = %File{source: context[:source1]} |> File.changeset(%{
      filepath: "/somewhere/file2",
      size: 100,
      mtime: DateTime.utc_now(),
      mode: 33188,
      atime: DateTime.utc_now(),
      ctime: DateTime.utc_now(),
      birthtime: DateTime.utc_now()
    }) |> Repo.insert

    {:ok, file3} = %File{source: context[:source2]} |> File.changeset(%{
      filepath: "/somewhere/file2",
      size: 100,
      mtime: DateTime.utc_now(),
      mode: 33188,
      atime: DateTime.utc_now(),
      ctime: DateTime.utc_now(),
      birthtime: DateTime.utc_now()
    }) |> Repo.insert

    files_from_source1 = context[:source1] |> File.list
    files_from_source1_ids = for f <- files_from_source1, do: f.id
    files_from_source2 = context[:source2] |> File.list
    files_from_source2_ids = for f <- files_from_source2, do: f.id

    assert length(files_from_source1) == 2
    assert length(files_from_source2) == 1
    assert file1.id in files_from_source1_ids
    assert file2.id in files_from_source1_ids
    refute file3.id in files_from_source1_ids
    assert file3.id in files_from_source2_ids
  end

  test "invalid file values", context do
    file1 = %File{} |> File.changeset(%{
      filepath: "/somewhere/file1",
      size: 100,
      mtime: DateTime.utc_now()
    })
    file2 = %File{source: context[:source1]} |> File.changeset(%{
      size: 100,
      mtime: DateTime.utc_now()
    })
    file3 = %File{source: context[:source1]} |> File.changeset(%{
      filepath: "/somewhere/file1",
      mtime: DateTime.utc_now()
    })
    file4 = %File{source: context[:source1]} |> File.changeset(%{
      filepath: "/somewhere/file1",
      size: 100
    })

    refute file1.valid?
    refute file2.valid?
    refute file3.valid?
    refute file4.valid?
  end

  defp get_file_transfer_query(%File{id: file_id}) do
    from ft in FileTransfer,
      where: ft.file_id == ^file_id,
      preload: :destination,
      preload: :file
  end

  test "create_or_update\\2 creates a file that doesn't exist", context do
    filename = "/a/random/file.txt"

    query = from f in File, where: f.filepath == ^filename, select: count(f.id)

    assert Repo.one(query) == 0

    {:ok, _new_file} = File.create_or_update(context[:source1], %{
      filepath: filename,
      size: 100,
      mtime: DateTime.utc_now()
    })

    assert Repo.one(query) == 1
  end

  test "create_or_update\\2 returns a file that already exists", context do
    filename = "/a/random/file1.txt"

    {:ok, new_file} = File.create_or_update(context[:source1], %{
      filepath: filename,
      size: 100,
      mtime: DateTime.utc_now()
    })
    file_transfers_new = Repo.all(get_file_transfer_query(new_file))

    {:ok, existing_file} = File.create_or_update(context[:source1], %{
      filepath: filename,
      size: 100,
      mtime: DateTime.utc_now()
    })

    assert new_file.id == existing_file.id

    query = from ft in FileTransfer,
      where: ft.file_id == ^existing_file.id,
      where: ft.status != "cancelled"
    file_transfers_existing = query |> Repo.all
    assert length(file_transfers_new) == length(file_transfers_existing)

  end

  test "add_file_transfers\\2 creates a set of FileTransfer records", context do
    {:ok, file} = %File{source: context[:source1]} |> File.changeset(%{
      filepath: "/somewhere/file1",
      size: 100,
      mtime: DateTime.utc_now()
    }) |> Repo.insert

    source = context[:source1] |> Repo.preload(:destinations)

    File.add_file_transfers(source.destinations, file)

    file_transfers = Repo.all(get_file_transfer_query(file))
    destination_bases = for ft <- file_transfers, do: ft.destination.base

    assert length(file_transfers) == 3
    assert "/destination/1/" in destination_bases
    assert "/destination/2/" in destination_bases
    assert "/destination/3/" in destination_bases
  end


  test "cancel_transfers\\1 cancels all file transfers for a file", context do
    {:ok, file} = %File{source: context[:source1]} |> File.changeset(%{
      filepath: "/somewhere/file1",
      size: 100,
      mtime: DateTime.utc_now()
    }) |> Repo.insert
    source = context[:source1] |> Repo.preload(:destinations)
    File.add_file_transfers(source.destinations, file)
    file_transfers = Repo.all(get_file_transfer_query(file))
    assert length(file_transfers) == 3
    File.cancel_transfers(file)
    file_transfers = Repo.all(get_file_transfer_query(file))
    Enum.map(
      file_transfers,
      fn ft ->
        assert ft.status == "cancelled"
      end)
  end

end
