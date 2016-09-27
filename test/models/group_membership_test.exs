defmodule EdmBackend.GroupMembershipModelTest do
  use EdmBackend.ModelCase
  alias EdmBackend.GroupMembership
  alias EdmBackend.Client
  alias EdmBackend.Group

  test "group membership validation" do
    client = %Client{} |> Client.changeset(%{
      name: "someone"
    })
    group = %Group{} |> Group.changeset(%{
      name: "a group",
      description: "a group description"
    })

    {:ok, client} = Repo.insert client
    {:ok, group} = Repo.insert group

    group_membership1 = %GroupMembership{} |> GroupMembership.changeset
    group_membership2 = %GroupMembership{
      client: client
    } |> GroupMembership.changeset
    group_membership3 = %GroupMembership{
      group: group
    } |> GroupMembership.changeset
    group_membership4 = %GroupMembership{
      client: client,
      group: group
    } |> GroupMembership.changeset

    refute group_membership1.valid?
    refute group_membership2.valid?
    refute group_membership3.valid?
    assert group_membership4.valid?
  end

  test "group membership uniqueness" do
    client = %Client{} |> Client.changeset(%{
      name: "someone"
    })
    group1 = %Group{} |> Group.changeset(%{
      name: "a group",
      description: "a group description"
    })
    group2 = %Group{} |> Group.changeset(%{
      name: "another group",
      description: "a group description"
    })

    {:ok, client} = Repo.insert client
    {:ok, group1} = Repo.insert group1
    {:ok, group2} = Repo.insert group2

    group_membership1 = %GroupMembership{
      client: client,
      group: group1
    } |> GroupMembership.changeset

    group_membership2 = %GroupMembership{
      client: client,
      group: group1
    } |> GroupMembership.changeset

    group_membership3 = %GroupMembership{
      client: client,
      group: group2
    } |> GroupMembership.changeset

    assert {:ok, _changeset} = Repo.insert group_membership1
    assert {:error, _changeset} = Repo.insert group_membership2
    assert {:ok, _changeset} = Repo.insert group_membership3
  end

end
