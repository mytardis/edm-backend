defmodule EdmBackend.ClientModelTest do
  use EdmBackend.ModelCase
  alias EdmBackend.Client

  test "valid client values" do
    client1 = %Client{} |> Client.changeset(%{
      uuid: "acfd51b2-0972-426a-acf1-2827f77fc97d",
      ip_address: "127.0.0.1"
    })
    client2 = %Client{} |> Client.changeset(%{
      uuid: "acfd51b2-0972-426a-acf1-2827f77fc97d",
      ip_address: "127.0.0.1",
      nickname: "a client"
    })
    client3 = %Client{} |> Client.changeset(%{
      uuid: "acfd51b2-0972-426a-acf1-2827f77fc97d",
      ip_address: "fe80::aebc:32ff:fe8d:f5e7",
      nickname: "a client"
    })

    assert client1.valid?
    assert client2.valid?
    assert client3.valid?
  end

  test "invalid client values" do
    client1 = %Client{} |> Client.changeset(%{
      uuid: "acfd51b2-0972-426a-acf1-2827f77fc97d"
    })
    client2 = %Client{} |> Client.changeset(%{
      ip_address: "127.0.0.1"
    })
    client3 = %Client{} |> Client.changeset(%{
      uuid: "acfd51b2-0972-426a-acf1-2827f77fc97q",
      ip_address: "127.0.0.1"
    })
    refute client1.valid?
    refute client2.valid?
    refute client3.valid?
  end

  test "client uniqueness" do
    client1 = %Client{} |> Client.changeset(%{
      uuid: "acfd51b2-0972-426a-acf1-2827f77fc97d",
      ip_address: "127.0.0.1"
    })
    client2 = %Client{} |> Client.changeset(%{
      uuid: "acfd51b2-0972-426a-acf1-2827f77fc97d",
      ip_address: "127.0.0.1"
    })
    client3 = %Client{} |> Client.changeset(%{
      uuid: "d1b60f27-39c9-4d1c-8468-b3ca7acf1aa4",
      ip_address: "127.0.0.1"
    })

    assert {:ok, _changeset} = Repo.insert client1
    assert {:error, _changeset} = Repo.insert client2
    assert {:ok, _changeset} = Repo.insert client3
  end

end
