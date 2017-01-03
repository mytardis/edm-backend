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
      file1: file
    ]
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

    File.create_file_transfers(destinations, file)

    file_transfers = file |> FileTransfer.get_transfers_for_file |> Repo.preload(:destination)
    destination_bases = for ft <- file_transfers, do: ft.destination.base

    assert length(file_transfers) == 2
    assert "/destination/1/" in destination_bases
    assert "/destination/2/" in destination_bases
  end

end
