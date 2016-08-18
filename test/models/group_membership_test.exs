defmodule EdmBackend.GroupMembershipModelTest do
  use EdmBackend.ModelCase
  alias EdmBackend.GroupMembership
  alias EdmBackend.User
  alias EdmBackend.Group

  test "group membership validation" do
    user = %User{
      name: "someone",
      email: "someone@example.com"
    } |> User.changeset
    group = %Group{
      name: "a group",
      description: "a group description"
    } |> Group.changeset

    {:ok, user} = Repo.insert user
    {:ok, group} = Repo.insert group

    group_membership1 = %GroupMembership{} |> GroupMembership.changeset
    group_membership2 = %GroupMembership{
      user: user
    } |> GroupMembership.changeset
    group_membership3 = %GroupMembership{
      group: group
    } |> GroupMembership.changeset
    group_membership4 = %GroupMembership{
      user: user,
      group: group
    } |> GroupMembership.changeset

    refute group_membership1.valid?
    refute group_membership2.valid?
    refute group_membership3.valid?
    assert group_membership4.valid?
  end

  test "group membership uniqueness" do
    user = %User{
      name: "someone",
      email: "someone@example.com"
    } |> User.changeset
    group1 = %Group{
      name: "a group",
      description: "a group description"
    } |> Group.changeset
    group2 = %Group{
      name: "another group",
      description: "a group description"
    } |> Group.changeset

    {:ok, user} = Repo.insert user
    {:ok, group1} = Repo.insert group1
    {:ok, group2} = Repo.insert group2

    group_membership1 = %GroupMembership{
      user: user,
      group: group1
    } |> GroupMembership.changeset

    group_membership2 = %GroupMembership{
      user: user,
      group: group1
    } |> GroupMembership.changeset

    group_membership3 = %GroupMembership{
      user: user,
      group: group2
    } |> GroupMembership.changeset

    assert {:ok, _changeset} = Repo.insert group_membership1
    assert {:error, _changeset} = Repo.insert group_membership2
    assert {:ok, _changeset} = Repo.insert group_membership3
  end

end
