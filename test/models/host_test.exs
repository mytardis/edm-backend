defmodule EdmBackend.HostTest do
  require Logger
  use EdmBackend.ModelCase
  alias EdmBackend.Repo
  alias EdmBackend.Client
  alias EdmBackend.Group
  alias EdmBackend.Host
  alias EdmBackend.Source
  alias EdmBackend.Destination

  setup do
    {:ok, owner1} = %Client{} |> Client.changeset(%{
      name: "test client1",
    }) |> Repo.insert
    {:ok, owner2} = %Client{} |> Client.changeset(%{
      name: "test client2",
    }) |> Repo.insert

    {:ok, group} = %Group{} |> Group.changeset(%{
      name: "test group",
      description: "a test group"
    }) |> Repo.insert

    [
      owner1: owner1,
      owner2: owner2,
      group: group
    ]
  end

  test "valid host values", context do
    host1 = %Host{group: context[:group]} |> Host.changeset(%{
      name: "some host",
      transfer_method: "sftp",
      settings: %{
        host: "some.host.edu.au",
        private_key: "AAAAAAAA"
      }
    })
    assert host1.valid?
  end

  test "invalid host values", context do
    host1 = %Host{} |> Host.changeset(%{
      name: "some host",
      transfer_method: "sftp",
      settings: %{
        host: "some.host.edu.au",
        private_key: "AAAAAAAA"
      }
    })
    host2 = %Host{group: context[:group]} |> Host.changeset(%{
      transfer_method: "sftp",
      settings: %{
        host: "some.host.edu.au",
        private_key: "AAAAAAAA"
      }
    })
    host3 = %Host{group: context[:group]} |> Host.changeset(%{
      name: "some host",
      settings: %{
        host: "some.host.edu.au",
        private_key: "AAAAAAAA"
      }
    })
    host4 = %Host{group: context[:group]} |> Host.changeset(%{
      name: "some host",
      transfer_method: "sftp"
    })

    refute host1.valid?
    refute host2.valid?
    refute host3.valid?
    refute host4.valid?
  end

  test "all_hosts\\1 returns all hosts for a client", context do
    # Create the Hosts
    {:ok, host1} = %Host{group: context[:group]} |> Host.changeset(%{
      name: "host1",
      transfer_method: "sftp",
      settings: %{
        host: "1some.host.edu.au",
        private_key: "AAAAAAAA"
      }
    }) |> Repo.insert
    {:ok, host2} = %Host{group: context[:group]} |> Host.changeset(%{
      name: "host2",
      transfer_method: "sftp",
      settings: %{
        host: "2some.host.edu.au",
        private_key: "AAAAAAAA"
      }
    }) |> Repo.insert
    {:ok, host3} = %Host{group: context[:group]} |> Host.changeset(%{
      name: "host3",
      transfer_method: "sftp",
      settings: %{
        host: "3some.host.edu.au",
        private_key: "AAAAAAAA"
      }
    }) |> Repo.insert

    {:ok, source1} = %Source{owner: context[:owner1]} |> Source.changeset(%{
      name: "test source 1",
      fstype: "POSIX"
    }) |> Repo.insert
    {:ok, source2} = %Source{owner: context[:owner2]} |> Source.changeset(%{
      name: "test source 2",
      fstype: "POSIX"
    }) |> Repo.insert

    {:ok, _destination1} = %Destination{host: host1, source: source1} |> Destination.changeset(%{
      base: "/some/base"
    }) |> Repo.insert
    {:ok, _destination2} = %Destination{host: host2, source: source1} |> Destination.changeset(%{
      base: "/some/other/base"
    }) |> Repo.insert
    {:ok, _destination3} = %Destination{host: host3, source: source2} |> Destination.changeset(%{
      base: "/yet/another/base"
    }) |> Repo.insert

    hosts_client1 = Host.all_hosts(context[:owner1])
    host_names_client1 = for h <- hosts_client1, do: h.name
    hosts_client2 = Host.all_hosts(context[:owner2])
    host_names_client2 = for h <- hosts_client2, do: h.name

    assert length(hosts_client1) == 2
    assert length(hosts_client2) == 1

    assert host1.name in host_names_client1
    assert host2.name in host_names_client1
    refute host3.name in host_names_client1

    refute host1.name in host_names_client2
    refute host2.name in host_names_client2
    assert host3.name in host_names_client2
  end

  test "group correctly identified by Group module", context do
    group = context[:group]
    {:ok, host} = %Host{group: group} |> Host.changeset(%{
      name: "host1",
      transfer_method: "sftp",
      settings: %{
        host: "1some.host.edu.au",
        private_key: "AAAAAAAA"
      }
    }) |> Repo.insert

    assert [^group] = Group.get_groups_for(host)
  end

end
