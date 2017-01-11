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

    assert {:ok, _group1} = Repo.insert group1
    assert {:error, _group2} = Repo.insert group2
    assert {:ok, _group3} = Repo.insert group3

  end
end
