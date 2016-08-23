defmodule EdmBackend.UserCredentialModelTest do
  use EdmBackend.ModelCase
  alias EdmBackend.UserCredential
  alias EdmBackend.User

  test "valid user credential values" do
    user = %User{} |> User.changeset(%{
      name: "test user",
      email: "user@example.com"
    })
    {:ok, user} = Repo.insert user

    user_credential1 = %UserCredential{
      user: user
    } |> UserCredential.changeset(%{
      auth_provider: "google",
      remote_id: "user@example.com",
      extra_data: "{ some: 'extra_data'}"
    })
    user_credential2 = %UserCredential{
      user: user
    } |> UserCredential.changeset(%{
      auth_provider: "google",
      remote_id: "user@example.com"
    })

    assert user_credential1.valid?
    assert user_credential2.valid?
  end

  test "invalid user credential values" do
    user = %User{} |> User.changeset(%{
      name: "test user",
      email: "user@example.com"
    })
    {:ok, user} = Repo.insert user

    user_credential1 = %UserCredential{
      user: user
    } |> UserCredential.changeset(%{
      remote_id: "user@example.com"
    })
    user_credential2 = %UserCredential{
      user: user
    } |> UserCredential.changeset(%{
      auth_provider: "google"
    })

    refute user_credential1.valid?
    refute user_credential2.valid?
  end

  test "user credential uniqueness" do
    user = %User{} |> User.changeset(%{
      name: "test user",
      email: "user@example.com"
    })
    {:ok, user} = Repo.insert user

    user_credential1 = %UserCredential{
      user: user
    } |> UserCredential.changeset(%{
      auth_provider: "google",
      remote_id: "user@example.com"
    })
    user_credential2 = %UserCredential{
      user: user
    } |> UserCredential.changeset(%{
      auth_provider: "google",
      remote_id: "user@example.com"
    })
    user_credential3 = %UserCredential{
      user: user
    } |> UserCredential.changeset(%{
      auth_provider: "monash",
      remote_id: "user@example.com"
    })

    assert {:ok, _changeset} = Repo.insert user_credential1
    assert {:error, _changeset} = Repo.insert user_credential2
    assert {:ok, _changeset} = Repo.insert user_credential3
  end

end
