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
    {:ok, client} = %Client{} |> Client.changeset(%{name: "test"}) |> Repo.insert
    assert [%{name: "test"}] = Group.get_groups_for(client)

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

    {:ok, _changeset} = client |> Client.add_to_group(group0)

    refute client |> Client.member_of?(empty_group)
    assert client |> Client.member_of?(group0)
    assert client |> Client.member_of?("a group")
    assert Enum.any?(Group.get_groups_for(client), fn(group) -> group.name == "a group" end)

    client |> Client.remove_member(group0)
    refute client |> Client.member_of?(group0)
    refute client |> Client.member_of?("a group")
  end

  test "default client group when name conflicts has suffix" do
    empty_group = %Group{} |> Group.changeset(%{
      name: "test",
      description: "a group description"
    })
    {:ok, _empty_group} = Repo.insert(empty_group)

    {:ok, client} = %Client{} |> Client.changeset(%{name: "test"}) |> Repo.insert
    assert [%{name: "test_1"}] = Group.get_groups_for(client)
  end

  test "client created from provider" do
    {:ok, client} = Client.get_or_create("test_provider", %{id: "123", name: "John Smith"}, %{some: "extra data"})
    assert client |> Client.member_of?("John Smith")
  end

end
