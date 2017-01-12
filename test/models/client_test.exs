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



    {:ok, _changeset} = client |> Client.add_to_group(group0)

    refute client |> Client.member_of?(empty_group)
    assert client |> Client.member_of?(group0)
    
    client |> Client.remove_from_group(group0)
    refute client |> Client.member_of?(group0)
  end

end
