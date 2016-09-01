defmodule EdmBackend.UserModelTest do
  use EdmBackend.ModelCase
  alias EdmBackend.User
  alias EdmBackend.Group

  require Logger

  test "valid user values" do
    user = %User{} |> User.changeset(%{
      name: "test user",
      email: "user@example.com"
    })

    assert user.valid?
  end

  test "user uniqueness" do
    user1 = %User{} |> User.changeset(%{
      name: "test user",
      email: "user@example.com"
    })
    user2 = %User{} |> User.changeset(%{
      name: "another test user",
      email: "user@example.com"
    })
    user3 = %User{} |> User.changeset(%{
      name: "yet another test user",
      email: "anotheruser@example.com"
    })

    assert {:ok, _changeset} = Repo.insert user1
    assert {:error, _changeset} = Repo.insert user2
    assert {:ok, _changeset} = Repo.insert user3
  end

  test "user group membership" do
    {:ok, user} = %User{name: "test", email: "another test"} |> Repo.insert

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

    {:ok, _changeset} = user |> User.add_to_group(group2a)
    {:ok, _changeset} = user |> User.add_to_group(group2b)

    all_group_membership_flat = user |> User.all_groups_flat
    all_group_membership = user |> User.all_groups

    assert length(all_group_membership_flat) == 4
    assert length(all_group_membership) == 2

    refute user |> User.member_of?(empty_group)
    assert user |> User.member_of?(group1)
    assert user |> User.member_of?(group2a)
    assert user |> User.member_of?(group2b)

    user |> User.remove_from_group(group2a)
    refute user |> User.member_of?(group2a)
  end

end
