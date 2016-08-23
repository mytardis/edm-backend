defmodule EdmBackend.GroupModelTest do
  use EdmBackend.ModelCase
  alias EdmBackend.Group

  test "valid group values" do
    group = %Group{} |> Group.changeset(%{
      name: "a group",
      description: "a group description"
    })

    assert group.valid?
  end

  test "invalid group values" do
    group1 = %Group{} |> Group.changeset
    group2 = %Group{} |> Group.changeset(%{name: "a group"})
    group3 = %Group{} |> Group.changeset(%{description: "a group description"})

    refute group1.valid?
    refute group2.valid?
    refute group3.valid?
  end

  test "group uniqueness" do

    # Test top-level groups
    group1 = %Group{} |> Group.changeset(%{
      name: "A",
      description: "_"
    })
    group2 = %Group{} |> Group.changeset(%{
      name: "A",
      description: "_"
    })
    group3 = %Group{} |> Group.changeset(%{
      name: "B",
      description: "_"
    })

    assert {:ok, group1} = Repo.insert group1
    assert {:error, _group2} = Repo.insert group2
    assert {:ok, group3} = Repo.insert group3

    # Test sub-groups
    sub_group1a = %Group{
      parent: group1
    } |> Group.changeset(%{
      name: "A",
      description: "_"
    })
    sub_group2a = %Group{
      parent: group1
    } |> Group.changeset(%{
      name: "A",
      description: "_"
    })
    sub_group3a = %Group{
      parent: group1
    } |> Group.changeset(%{
      name: "B",
      description: "_"
    })

    assert {:ok, _changeset} = Repo.insert sub_group1a
    assert {:error, _changeset} = Repo.insert sub_group2a
    assert {:ok, _changeset} = Repo.insert sub_group3a

    sub_group1b = %Group{
      parent: group3
    } |> Group.changeset(%{
      name: "A",
      description: "_"
    })
    sub_group2b = %Group{
      parent: group3
    } |> Group.changeset(%{
      name: "A",
      description: "_"
    })
    sub_group3b = %Group{
      parent: group3
    } |> Group.changeset(%{
      name: "B",
      description: "_"
    })

    assert {:ok, _changeset} = Repo.insert sub_group1b
    assert {:error, _changeset} = Repo.insert sub_group2b
    assert {:ok, _changeset} = Repo.insert sub_group3b

  end

  test "group hierarchy" do
    parent_group = %Group{} |> Group.changeset(%{
      name: "a parent group",
      description: "a parent group description"
    })

    {:ok, parent_group} = Repo.insert parent_group

    child_group = %Group{
      parent: parent_group
    } |> Group.changeset(%{
      name: "a child group",
      description: "a sub group description"
    })

    {:ok, child_group} = Repo.insert child_group

    assert %Group{children: [%Group{name: "a child group"}]} = Group.load_children parent_group
    assert %Group{parent: %Group{name: "a parent group"}} = Group.load_parents child_group
  end

end
