defmodule EdmBackend.DestinationModelTest do
  require Logger
  use EdmBackend.ModelCase
  alias EdmBackend.Repo
  alias EdmBackend.Source
  alias EdmBackend.Client
  alias EdmBackend.File
  alias EdmBackend.Host
  alias EdmBackend.Group
  alias EdmBackend.Destination

  setup do
      {:ok, owner} = %Client{} |> Client.changeset(%{
        name: "test client",
      }) |> Repo.insert

      {:ok, source1} = %Source{owner: owner} |> Source.changeset(%{
        name: "test source1",
        fstype: "testfs"
      }) |> Repo.insert
      {:ok, source2} = %Source{owner: owner} |> Source.changeset(%{
        name: "test source2",
        fstype: "testfs"
      }) |> Repo.insert

      {:ok, file1} = %File{source: source1} |> File.changeset(%{
        filepath: "/somewhere/file1",
        size: 100,
        mtime: DateTime.utc_now()
      }) |> Repo.insert
      {:ok, file2} = %File{source: source2} |> File.changeset(%{
        filepath: "/somewhere/file2",
        size: 100,
        mtime: DateTime.utc_now()
      }) |> Repo.insert

      {:ok, group} = %Group{} |> Group.changeset(%{
        name: "test group",
        description: "a test group"
      }) |> Repo.insert

      {:ok, host1} = %Host{group: group} |> Host.changeset(%{
        name: "test host1",
        transfer_method: "sftp",
        settings: %{}
      }) |> Repo.insert
      {:ok, host2} = %Host{group: group} |> Host.changeset(%{
        name: "test host2",
        transfer_method: "sftp",
        settings: %{}
      }) |> Repo.insert

      [
        file1: file1,
        file2: file2,
        source1: source1,
        source2: source2,
        host1: host1,
        host2: host2
      ]
  end

  test "destination belongs to the same group as the host", context do
    {:ok, destination} = %Destination{
      host: context[:host1],
      source: context[:source1]
    } |> Destination.changeset(%{
      base: "/destination1/source1/"
    }) |> Repo.insert
    [destination_group] = Group.get_groups_for(destination)
    assert destination_group.name == "test group"
  end

  test "valid destination values", context do
    destination = %Destination{
      host: context[:host1],
      source: context[:source1]
    } |> Destination.changeset(%{
      base: "/some/base"
    })
    assert destination.valid?
  end

  test "invalid destination values", context do
    destination1 = %Destination{
      source: context[:source1]
    } |> Destination.changeset(%{
      base: "/some/base"
    })

    destination2 = %Destination{
      host: context[:host1]
    } |> Destination.changeset(%{
      base: "/some/base"
    })

    destination3 = %Destination{
      host: context[:host1],
      source: context[:source1]
    } |> Destination.changeset()

    refute destination1.valid?
    refute destination2.valid?
    refute destination3.valid?
  end

  test "all_destinations\\1 function returns all destinations", context do
    {:ok, destination1_source1} = %Destination{
      host: context[:host1],
      source: context[:source1]
    } |> Destination.changeset(%{
      base: "/destination1/source1/"
    }) |> Repo.insert

    {:ok, destination2_source1} = %Destination{
      host: context[:host1],
      source: context[:source1]
    } |> Destination.changeset(%{
      base: "/destination2/source1/"
    }) |> Repo.insert

    {:ok, destination1_source2} = %Destination{
      host: context[:host1],
      source: context[:source2]
    } |> Destination.changeset(%{
      base: "/destination1/source2/"
    }) |> Repo.insert

    source1_destinations = context[:source1] |> Destination.all_destinations
    source1_bases = for d <- source1_destinations, do: d.base
    source2_destinations = context[:source2] |> Destination.all_destinations
    source2_bases = for d <- source2_destinations, do: d.base

    assert length(source1_bases) == 2
    assert length(source2_bases) == 1

    assert destination1_source1.base in source1_bases
    assert destination2_source1.base in source1_bases
    refute destination1_source2.base in source1_bases

    assert destination1_source2.base in source2_bases
    refute destination1_source1.base in source2_bases
    refute destination2_source1.base in source2_bases
  end

end
