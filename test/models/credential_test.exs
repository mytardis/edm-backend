defmodule EdmBackend.CredentialModelTest do
  use EdmBackend.ModelCase
  alias EdmBackend.Credential
  alias EdmBackend.Client

  test "valid credential values" do
    client = %Client{} |> Client.changeset(%{
      name: "test user"
    })
    {:ok, client} = Repo.insert client

    credential1 = %Credential{
      client: client
    } |> Credential.changeset(%{
      auth_provider: "google",
      remote_id: "user@example.com",
      extra_data: %{ some: "extra_data"}
    })
    credential2 = %Credential{
      client: client
    } |> Credential.changeset(%{
      auth_provider: "google",
      remote_id: "user@example.com"
    })

    assert credential1.valid?
    assert credential2.valid?
  end

  test "invalid credential values" do
    client = %Client{} |> Client.changeset(%{
      name: "test user"
    })
    {:ok, client} = Repo.insert client

    credential1 = %Credential{
      client: client
    } |> Credential.changeset(%{
      remote_id: "user@example.com"
    })
    credential2 = %Credential{
      client: client
    } |> Credential.changeset(%{
      auth_provider: "google"
    })

    refute credential1.valid?
    refute credential2.valid?
  end

  test "credential uniqueness" do
    client = %Client{} |> Client.changeset(%{
      name: "test user"
    })
    {:ok, client} = Repo.insert client

    credential1 = %Credential{
      client: client
    } |> Credential.changeset(%{
      auth_provider: "google",
      remote_id: "user@example.com"
    })
    credential2 = %Credential{
      client: client
    } |> Credential.changeset(%{
      auth_provider: "google",
      remote_id: "user@example.com"
    })
    credential3 = %Credential{
      client: client
    } |> Credential.changeset(%{
      auth_provider: "monash",
      remote_id: "user@example.com"
    })

    assert {:ok, _changeset} = Repo.insert credential1
    assert {:error, _changeset} = Repo.insert credential2
    assert {:ok, _changeset} = Repo.insert credential3
  end

end
