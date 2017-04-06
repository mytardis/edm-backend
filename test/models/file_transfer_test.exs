defmodule EdmBackend.FileTransferTest do
  require Logger
  use EdmBackend.ModelCase
  alias EdmBackend.Repo
  alias EdmBackend.FileTransfer
  alias EdmBackend.Client
  alias EdmBackend.Source
  alias EdmBackend.Group
  alias EdmBackend.Host
  alias EdmBackend.Destination
  alias EdmBackend.File

  setup do
    {:ok, owner} = %Client{} |> Client.changeset(%{
      name: "test client",
    }) |> Repo.insert

    {:ok, source} = %Source{owner: owner} |> Source.changeset(%{
      name: "test source",
      fstype: "testfs"
    }) |> Repo.insert

    {:ok, group} = %Group{} |> Group.changeset(%{
      name: "test group",
      description: "a test group"
    }) |> Repo.insert

    {:ok, host} = %Host{group: group} |> Host.changeset(%{
      name: "test host",
      transfer_method: "sftp",
      settings: %{}
    }) |> Repo.insert

    {:ok, destination1} = %Destination{
      host: host,
      source: source
    } |> Destination.changeset(%{
      base: "/destination/1/"
    }) |> Repo.insert

    {:ok, destination2} = %Destination{
      host: host,
      source: source
    } |> Destination.changeset(%{
      base: "/destination/2/"
    }) |> Repo.insert

    {:ok, file} = %File{source: source} |> File.changeset(%{
      filepath: "/somewhere/file1",
      size: 100,
      mtime: DateTime.utc_now()
    }) |> Repo.insert

    [
      destination1: destination1,
      destination2: destination2,
      file1: file,
      source1: source,
    ]
  end

  test "file transfers belong to the same group as the client", context do
    {:ok, file_transfer} = %FileTransfer{
      file: context[:file1],
      destination: context[:destination1]
    } |> FileTransfer.changeset(%{
      status: "new"
    }) |> Repo.insert
    [%{name: "test client"}] = Group.get_groups_for(file_transfer)
  end

  test "valid file_transfer values", context do
    # Minimal
    file_transfer1 = %FileTransfer{
      file: context[:file1],
      destination: context[:destination1]
    } |> FileTransfer.changeset(%{
      status: "new"
    })

    # Everything
    file_transfer2 = %FileTransfer{
      file: context[:file1],
      destination: context[:destination1]
    } |> FileTransfer.changeset(%{
      status: "new",
      bytes_transferred: 100
    })

    assert file_transfer1.valid?
    assert file_transfer2.valid?
  end

  test "invalid file_transfer values", context do
    file_transfer1 = %FileTransfer{
      file: context[:file1],
      destination: context[:destination1]
    } |> FileTransfer.changeset(%{})
    file_transfer2 = %FileTransfer{
      file: context[:file1]
    } |> FileTransfer.changeset(%{
      status: "new"
    })
    file_transfer3 = %FileTransfer{
      destination: context[:destination1]
    } |> FileTransfer.changeset(%{
      status: "new"
    })

    refute file_transfer1.valid?
    refute file_transfer2.valid?
    refute file_transfer3.valid?
  end

  test "get_transfers_for_file\\1 function returns all transfers", context do
    file = context[:file1]
    destinations = [context[:destination1], context[:destination2]]

    File.add_file_transfers(destinations, file)

    file_transfers = file |> FileTransfer.get_transfers_for_file |> Repo.preload(:destination)
    destination_bases = for ft <- file_transfers, do: ft.destination.base

    assert length(file_transfers) == 2
    assert "/destination/1/" in destination_bases
    assert "/destination/2/" in destination_bases
  end

  test "cancel_transfer\\1 cancels one incomplete file transfers", context do

    {:ok, new_file} = File.create_or_update(
      context[:source1],
      %{
          filepath: "/some/file",
          size: 12,
          mtime: DateTime.utc_now(),
      })

    [ft | _] = Repo.all(from ft in FileTransfer,
        where: ft.file_id == ^new_file.id,
        preload: :destination,
        preload: :file)

    EdmBackend.FileTransfer.cancel_transfer(ft)
    query = from ft in FileTransfer,
      where: ft.id == ^ft.id
    ft = query |> Repo.one
    assert ft.status == "cancelled"
  end

end
