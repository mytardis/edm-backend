defmodule EdmBackend.GroupModelTest do
  use EdmBackend.ModelCase
  alias EdmBackend.Group

  test "valid group values" do
    group = %Group{
      name: "a group",
      description: "a group description"
    } |> Group.changeset

    assert group.valid?
  end

  test "invalid group values" do
    group1 = %Group{} |> Group.changeset
    group2 = %Group{name: "a group"} |> Group.changeset
    group3 = %Group{description: "a group description"} |> Group.changeset

    refute group1.valid?
    refute group2.valid?
    refute group3.valid?
  end

  test "group uniqueness" do

    # Test top-level groups
    group1 = %Group{
      name: "A",
      description: "_"
    } |> Group.changeset
    group2 = %Group{
      name: "A",
      description: "_"
    } |> Group.changeset
    group3 = %Group{
      name: "B",
      description: "_"
    } |> Group.changeset

    assert {:ok, group1} = Repo.insert group1
    assert {:error, group2} = Repo.insert group2
    assert {:ok, group3} = Repo.insert group3

    # Test sub-groups
    sub_group1a = %Group{
      name: "A",
      description: "_",
      parent: group1
    } |> Group.changeset
    sub_group2a = %Group{
      name: "A",
      description: "_",
      parent: group1
    } |> Group.changeset
    sub_group3a = %Group{
      name: "B",
      description: "_",
      parent: group1
    } |> Group.changeset

    assert {:ok, _changeset} = Repo.insert sub_group1a
    assert {:error, _changeset} = Repo.insert sub_group2a
    assert {:ok, _changeset} = Repo.insert sub_group3a

    sub_group1b = %Group{
      name: "A",
      description: "_",
      parent: group3
    } |> Group.changeset
    sub_group2b = %Group{
      name: "A",
      description: "_",
      parent: group3
    } |> Group.changeset
    sub_group3b = %Group{
      name: "B",
      description: "_",
      parent: group3
    } |> Group.changeset

    assert {:ok, _changeset} = Repo.insert sub_group1b
    assert {:error, _changeset} = Repo.insert sub_group2b
    assert {:ok, _changeset} = Repo.insert sub_group3b

  end

  test "group hierarchy" do
    parent_group = %Group{
      name: "a parent group",
      description: "a parent group description"
    } |> Group.changeset

    {:ok, parent_group} = Repo.insert parent_group

    child_group = %Group{
      name: "a child group",
      description: "a sub group description",
      parent: parent_group
    }

    {:ok, child_group} = Repo.insert child_group

    assert %Group{children: [%Group{name: "a child group"}]} = Group.load_children parent_group
    assert %Group{parent: %Group{name: "a parent group"}} = Group.load_parents child_group
  end

end
