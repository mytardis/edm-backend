defmodule EdmBackend.ClientModelTest do
  require Logger
  use EdmBackend.ModelCase
  alias EdmBackend.Client
  alias EdmBackend.Group

  test "valid client values" do
    client = %Client{} |> Client.changeset(%{
      name: "test client"
    })

    assert client.valid?
  end

  test "client group membership" do
    {:ok, client} = %Client{name: "test"} |> Repo.insert

    empty_group = %Group{} |> Group.changeset(%{
      name: "group with no members",
      description: "a group description"
    })
    {:ok, empty_group} = Repo.insert empty_group

    group0 = %Group{} |> Group.changeset(%{
      name: "a group",
      description: "a group description"
    })
    {:ok, group0} = Repo.insert group0

    group1 = %Group{parent: group0} |> Group.changeset(%{
      name: "another group",
      description: "a group description"
    })
    {:ok, group1} = Repo.insert group1

    group2a = %Group{parent: group1} |> Group.changeset(%{
      name: "yet another group (a)",
      description: "a group description"
    })
    {:ok, group2a} = Repo.insert group2a

    group2b = %Group{parent: group1} |> Group.changeset(%{
      name: "yet another group (b)",
      description: "a group description"
    })
    {:ok, group2b} = Repo.insert group2b

    {:ok, _changeset} = client |> Client.add_to_group(group2a)
    {:ok, _changeset} = client |> Client.add_to_group(group2b)

    all_group_membership_flat = client |> Client.all_groups_flat
    all_group_membership = client |> Client.all_groups

    assert length(all_group_membership_flat) == 4
    assert length(all_group_membership) == 2

    refute client |> Client.member_of?(empty_group)
    assert client |> Client.member_of?(group1)
    assert client |> Client.member_of?(group2a)
    assert client |> Client.member_of?(group2b)

    client |> Client.remove_from_group(group2a)
    refute client |> Client.member_of?(group2a)
  end

end
