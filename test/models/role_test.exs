defmodule EdmBackend.RoleTest do
  use EdmBackend.ModelCase
  alias EdmBackend.Role
  alias EdmBackend.Client
  alias EdmBackend.Source
  alias EdmBackend.File

  setup do
    {:ok, client1} = Client.get_or_create("test provider", %{name: "Test Client 1", id: "123"})
    {:ok, client2} = Client.get_or_create("test provider", %{name: "Test Client 2", id: "456"})
    {:ok, client3} = Client.get_or_create("test provider", %{name: "Test Client 3", id: "789"})
    {:ok, source_client2} = Source.get_or_create(client2, %{
      name: "source1",
      fstype: "POSIX"
    })
    {:ok, source_client3} = Source.get_or_create(client3, %{
      name: "source2",
      fstype: "POSIX"
    })
    {:ok, file_client2} = File.create_or_update(source_client2, %{
      filepath: "/somewhere/file1",
      size: 100,
      mtime: DateTime.utc_now()
    })
    {:ok, file_client3} = File.create_or_update(source_client3, %{
      filepath: "/somewhere/file2",
      size: 100,
      mtime: DateTime.utc_now()
    })
    [
      client1: client1,
      client2: client2,
      client3: client3,
      source_client2: source_client2,
      source_client3: source_client3,
      file_client2: file_client2,
      file_client3: file_client3
    ]
  end

  test "create and apply roles", context do
    # Note: "Test Client x" are group names autogenerated upon user creation
    {:ok, _role_admin} = Role.create("admin role", "admin", "Test Client 1", "Test Client 2")
    {:ok, _role_viewer1} = Role.create("viewer role", "viewer", "Test Client 1", "Test Client 2")
    {:ok, _role_viewer2} = Role.create("viewer role", "viewer", "Test Client 1", "Test Client 3")

    assert Role.has_role?("admin", context[:client1], context[:source_client2])
    assert Role.has_role?("admin", context[:client1], context[:file_client2])
    refute Role.has_role?("admin", context[:client1], context[:source_client3])
    refute Role.has_role?("admin", context[:client1], context[:file_client3])

    assert Role.has_role?("viewer", context[:client1], context[:source_client2])
    assert Role.has_role?("viewer", context[:client1], context[:file_client2])
    assert Role.has_role?("viewer", context[:client1], context[:source_client3])
    assert Role.has_role?("viewer", context[:client1], context[:file_client3])

    assert Role.has_role?(:admin, context[:client1], context[:source_client2])
    assert Role.has_role?(:admin, context[:client1], context[:file_client2])
    refute Role.has_role?(:admin, context[:client1], context[:source_client3])
    refute Role.has_role?(:admin, context[:client1], context[:file_client3])

    assert Role.has_role?(:viewer, context[:client1], context[:source_client2])
    assert Role.has_role?(:viewer, context[:client1], context[:file_client2])
    assert Role.has_role?(:viewer, context[:client1], context[:source_client3])
    assert Role.has_role?(:viewer, context[:client1], context[:file_client3])
  end
end
