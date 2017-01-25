defmodule EdmBackend.SourceModelTest do
  require Logger
  use EdmBackend.ModelCase
  alias EdmBackend.Source
  alias EdmBackend.Client
  alias EdmBackend.Group

  setup do
    {:ok, owner1} = %Client{} |> Client.changeset(%{
      name: "test client1",
    }) |> Repo.insert
    {:ok, owner2} = %Client{} |> Client.changeset(%{
      name: "test client2",
    }) |> Repo.insert

    [
      owner1: owner1,
      owner2: owner2
    ]
  end

  test "valid source values", context do
    valid_source = %Source{owner: context[:owner1]} |> Source.changeset(%{
      name: "test source",
      fstype: "POSIX"
    })

    assert valid_source.valid?
  end

  test "invalid source values", context do
    invalid_source = %Source{owner: context[:owner1]} |> Source.changeset(%{
      name: "test source"
    })

    refute invalid_source.valid?
  end

  test "all_sources\\1 returns all sources for a client", context do
    {:ok, source1_owner1} = %Source{owner: context[:owner1]} |> Source.changeset(%{
      name: "source1",
      fstype: "POSIX"
    }) |> Repo.insert
    {:ok, source2_owner1} = %Source{owner: context[:owner1]} |> Source.changeset(%{
      name: "source2",
      fstype: "POSIX"
    }) |> Repo.insert
    {:ok, source1_owner2} = %Source{owner: context[:owner2]} |> Source.changeset(%{
      name: "source3",
      fstype: "POSIX"
    }) |> Repo.insert

    owner1_sources = context[:owner1] |> Source.all_sources
    owner1_source_names = for s <- owner1_sources, do: s.name
    owner2_sources = context[:owner2] |> Source.all_sources
    owner2_source_names = for s <- owner2_sources, do: s.name

    assert length(owner1_source_names) == 2
    assert length(owner2_source_names) == 1

    assert source1_owner1.name in owner1_source_names
    assert source2_owner1.name in owner1_source_names
    refute source1_owner2.name in owner1_source_names

    assert source1_owner2.name in owner2_source_names
    refute source1_owner1.name in owner2_source_names
    refute source2_owner1.name in owner2_source_names
  end

  test "find\\2 lists all sources for a client with the a given name", context do
    {:ok, _source1_owner1} = %Source{owner: context[:owner1]} |> Source.changeset(%{
      name: "source4",
      fstype: "POSIX"
    }) |> Repo.insert
    {:ok, _source2_owner1} = %Source{owner: context[:owner1]} |> Source.changeset(%{
      name: "source5",
      fstype: "POSIX"
    }) |> Repo.insert
    {:ok, _source1_owner2} = %Source{owner: context[:owner2]} |> Source.changeset(%{
      name: "source6",
      fstype: "POSIX"
    }) |> Repo.insert

    assert {:ok, %{name: "source4"}} = Source.find(context[:owner1], "source4")
    assert {:ok, %{name: "source5"}} = Source.find(context[:owner1], "source5")
    assert {:ok, %{name: "source6"}} = Source.find(context[:owner2], "source6")
    assert {:error, _} = Source.find(context[:owner2], "source4")
    assert {:error, _} = Source.find(context[:owner2], "source5")
    assert {:error, _} = Source.find(context[:owner1], "source6")
  end

  test "get_or_create\\2 creates a source that doesn't exist", context do
    # Check that the source currently doesn't exist
    assert {:error, _} = Source.find(context[:owner1], "source7")
    Source.get_or_create(context[:owner1], %{
      name: "source7",
      fstype: "POSIX"
    })
    # Check that the source now exists in the database
    assert {:ok, %{name: "source7", fstype: "POSIX"}} = Source.find(context[:owner1], "source7")
  end

  test "get_or_create\\2 returns a source that already exists", context do
    {:ok, source} = %Source{owner: context[:owner1]} |> Source.changeset(%{
      name: "source8",
      fstype: "POSIX"
    }) |> Repo.insert

    id = source.id
    assert {:ok, %{id: ^id}} = Source.get_or_create(context[:owner1], %{name: "source8"})
  end

  test "sources belong to the same group as the client", context do
    {:ok, source} = %Source{owner: context[:owner1]} |> Source.changeset(%{
      name: "source",
      fstype: "POSIX"
    }) |> Repo.insert
    assert [%{name: "test client1"}] = Group.get_groups_for(source)
  end
end
