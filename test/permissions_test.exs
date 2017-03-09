defmodule EdmBackend.PermissionsTest do
  use EdmBackend.ModelCase
  import Canada, only: [can?: 2]
  alias EdmBackend.Client
  alias EdmBackend.Source
  alias EdmBackend.Role
  alias EdmBackend.Repo

  setup do
    {:ok, actor_client} = Client.get_or_create(:test_provider, %{name: "Actor", id: "123"})
    {:ok, subject_client} = Client.get_or_create(:test_provider, %{name: "Subject", id: "456"})
    {:ok, actor_source} = actor_client |> Source.get_or_create(%{
      name: "source",
      fstype: "POSIX"
    })
    {:ok, subject_source} = subject_client |> Source.get_or_create(%{
      name: "source",
      fstype: "POSIX"
    })

    [
      actor: actor_client,
      subject: subject_client,
      actor_source: actor_source,
      subject_source: subject_source
    ]
  end

  test "A client can view itself", context do
    assert context[:actor] |> can?(view(context[:actor]))
    refute context[:actor] |> can?(view(context[:subject]))
  end

  test "A client can manage its own sources", context do
    assert context[:actor] |> can?(view(context[:actor_source]))
    refute context[:actor] |> can?(view(context[:subject_source]))

    assert context[:actor] |> can?(update(context[:actor_source]))
    refute context[:actor] |> can?(update(context[:subject_source]))

    assert context[:actor] |> can?(create(context[:actor_source]))
    refute context[:actor] |> can?(create(context[:subject_source]))

    assert context[:actor] |> can?(delete(context[:actor_source]))
    refute context[:actor] |> can?(delete(context[:subject_source]))
  end

  test "A client can get a token for itself", context do
    assert context[:actor] |> can?(impersonate(context[:actor]))
    refute context[:actor] |> can?(impersonate(context[:subject]))
  end

  test "A client who is an administrator can get a token for another client", context do
    {:ok, _role} = Role.create("admin role", :admin, "Actor", "Subject")
    assert context[:actor] |> can?(impersonate(context[:subject]))
    refute context[:subject] |> can?(impersonate(context[:actor]))
  end

  test "A client with the appropriate role can perform a specific action on a subject", context do
    # No role assigned, nothing is possible
    refute context[:actor] |> can?(view(context[:subject_source]))
    refute context[:actor] |> can?(update(context[:subject_source]))
    refute context[:actor] |> can?(create(context[:subject_source]))
    refute context[:actor] |> can?(delete(context[:subject_source]))

    # Assigning admin role, everything possible
    {:ok, admin_role} = Role.create("admin role", :admin, "Actor", "Subject")
    assert context[:actor] |> can?(view(context[:subject_source]))
    assert context[:actor] |> can?(update(context[:subject_source]))
    assert context[:actor] |> can?(create(context[:subject_source]))
    assert context[:actor] |> can?(delete(context[:subject_source]))

    # Removing admin role, adding viewer role
    {:ok, _} = admin_role |> Repo.delete
    {:ok, _viewer_role} = Role.create("viewer role", :viewer, "Actor", "Subject")
    assert context[:actor] |> can?(view(context[:subject_source]))
    refute context[:actor] |> can?(update(context[:subject_source]))
    refute context[:actor] |> can?(create(context[:subject_source]))
    refute context[:actor] |> can?(delete(context[:subject_source]))
  end
end
