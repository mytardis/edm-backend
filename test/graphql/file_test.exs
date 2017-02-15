defmodule EdmBackend.FileMutationTest do
  require Logger
  use EdmBackend.GraphQLCase
  alias EdmBackend.Repo
  alias EdmBackend.Client
  alias EdmBackend.Source
  alias EdmBackend.File
  alias EdmBackend.Role
  alias EdmBackend.Group
  alias EdmBackend.Host
  alias EdmBackend.Destination

  setup do
    {:ok, owner} = %Client{} |> Client.changeset(%{
      name: "test client",
    }) |> Repo.insert
    Client.create_default_group(owner)

    {:ok, source} = %Source{owner: owner} |> Source.changeset(%{
      name: "test source",
      fstype: "POSIX"
    }) |> Repo.insert

    {:ok, file} = %File{source: source} |> File.changeset(%{
      filepath: "testfile3.txt",
      atime: "2013-06-05T06:40:25.000000Z",
      birthtime: "2013-06-05T06:40:25.000000Z",
      ctime: "2013-06-05T06:40:25.000000Z",
      mode: 100644,
      mtime: "2013-06-05T06:40:25.000000Z",
      size: 12
    }) |> Repo.insert

    [client: owner, source: source, existing_file: file]
  end

  defp create_or_update_file_query(file_info, source_info) when is_map(source_info) do
    file_info_json = Poison.encode!(file_info)
    source_info_json = Poison.encode!(source_info)

    """
{"query": "mutation createOrUpdateFile($input: CreateOrUpdateFileInput!) {
  createOrUpdateFile(input: $input) {
            clientMutationId
            file {
              filepath
              size
              atime
              ctime
              mtime
              birthtime
              mode
              source {
                id
                owner {
                  id
                }
              }
            }
        }
    }",
"variables": {
  "input": {
    "clientMutationId": "123",
    "source": #{source_info_json},
    "file": #{file_info_json}
  }
}
}
    """
  end

  defp create_or_update_file_query(file_info, owner_id, source_info) when is_map(source_info) do
    file_info_json = Poison.encode!(file_info)
    source_info_json = Poison.encode!(source_info)

    """
{"query": "mutation createOrUpdateFile($input: CreateOrUpdateFileInput!) {
  createOrUpdateFile(input: $input) {
            clientMutationId
            file {
              filepath
              size
              atime
              ctime
              mtime
              birthtime
              mode
              source {
                owner {
                  id
                }
              }
            }
        }
    }",
"variables": {
  "input": {
    "clientMutationId": "123",
    "clientId": "#{owner_id}",
    "source": #{source_info_json},
    "file": #{file_info_json}
  }
}
}
    """
  end

  defp update_file_query(file_info, id) do
    file_info_json = Poison.encode!(file_info)

    """
{"query": "mutation updateFile($input: UpdateFileInput!) {
  updateFile(input: $input) {
            clientMutationId
            file {
              filepath
              size
              atime
              ctime
              mtime
              birthtime
              mode
            }
        }
    }",
"variables": {
  "input": {
    "fileId": "#{id}",
    "clientMutationId": "123",
    "file": #{file_info_json}
  }
}
}
    """
  end

  defp delete_file_query(id) do
    """
{"query": "mutation deleteFile($input: ID!) {
  deleteFile(input: $input) {
            clientMutationId
            file {
              filepath
              size
              atime
              ctime
              mtime
              birthtime
              mode
            }
        }
    }",
"variables": {
  "input": {
    "clientMutationId": "123",
    "fileId": "#{id}"
  }
}
}
    """
  end

  defp get_file_transfers_for_file_query(id) do
    """
{"query": "query getFileTransfers($id: ID!) {
 	node(id: $id) {
    ... on File {
      fileTransfers(first:10) {
        edges {
          node {
            status
            bytesTransferred
            destination {
              name
              base
              host {
                id
                transferMethod
              }
            }
          }
        }
      }
    }
  }
}",
"variables": {
  "id": "#{id}"
  }
}
    """
  end

  defp get_source_id(source) do
    Absinthe.Relay.Node.to_global_id(:source, source.id, EdmBackend.GraphQL.Schema)
  end

  defp get_client_id(client) do
    Absinthe.Relay.Node.to_global_id(:client, client.id, EdmBackend.GraphQL.Schema)
  end

  defp get_file_id(file) do
    Absinthe.Relay.Node.to_global_id(:file, file.id, EdmBackend.GraphQL.Schema)
  end

  defp get_host_id(host) do
    Absinthe.Relay.Node.to_global_id(:host, host.id, EdmBackend.GraphQL.Schema)
  end

  test "creating a file with existing source by source info", context do
    client = context[:client]
    file_info = %{
        "filepath" => "testfile3.txt",
        "atime" => "2013-06-05T06:40:25.000000Z",
        "birthtime" => "2013-06-05T06:40:25.000000Z",
        "ctime" => "2013-06-05T06:40:25.000000Z",
        "mode" => 100644,
        "mtime" => "2013-06-05T06:40:25.000000Z",
        "size" => 12
    }
    source = context[:source]
    source_info = %{
      "name" => source.name,
      "fstype" => source.fstype
    }
    owner_id = get_client_id(client)
    source_id = get_source_id(source)
    query = file_info |> create_or_update_file_query(source_info)
    assert_errors(query, [%{locations: [%{column: 0, line: 2}],
      message: "In field \"createOrUpdateFile\": Not logged in"}])
    assert_data(query, %{"createOrUpdateFile" => %{
      "clientMutationId" => "123",
      "file" => Map.merge(file_info, %{
          "source" => %{
            "id" => source_id,
            "owner" => %{"id" => owner_id}
          }
        }),
       }}, client)
  end

  test "creating a file for another client", context do
    creator = context[:client]

    {:ok, client} = %Client{} |> Client.changeset(%{
      name: "test client2",
    }) |> Repo.insert

    # Add the role that allows the creator to update the client
    Client.create_default_group(creator)
    Client.create_default_group(client)
    Role.create("admin role", :admin, creator.name, client.name)

    file_info = %{
        "filepath" => "testfile3.txt",
        "atime" => "2013-06-05T06:40:25.000000Z",
        "birthtime" => "2013-06-05T06:40:25.000000Z",
        "ctime" => "2013-06-05T06:40:25.000000Z",
        "mode" => 100644,
        "mtime" => "2013-06-05T06:40:25.000000Z",
        "size" => 12
    }

    source = context[:source]
    source_info = %{
      "name" => source.name,
      "fstype" => source.fstype
    }
    owner_id = get_client_id(client)
    query = file_info |> create_or_update_file_query(owner_id, source_info)
    assert_errors(query, [%{locations: [%{column: 0, line: 2}],
      message: "In field \"createOrUpdateFile\": Not logged in"}])
    assert_data(query, %{"createOrUpdateFile" => %{
      "clientMutationId" => "123",
      "file" => Map.merge(file_info, %{
          "source" => %{
            "owner" => %{"id" => owner_id}
          }
        }),
       }}, creator)
  end

  test "update a file", context do
    client = context[:client]

    current_file_info = %{
        "filepath" => "testfile4.txt",
        "atime" => "2013-06-05T06:40:25.000000Z",
        "birthtime" => "2013-06-05T06:40:25.000000Z",
        "ctime" => "2013-06-05T06:40:25.000000Z",
        "mode" => 100644,
        "mtime" => "2013-06-05T06:40:25.000000Z",
        "size" => 12
    }

    # Update the file...
    new_file_info = %{
        "filepath" => "testfile4.txt",
        "mode" => 100777,
        "size" => 120
    }

    query = new_file_info |> update_file_query(get_file_id(context[:existing_file]))

    # Confirm that the updated file contains the updated parameters
    assert_data(query, %{"updateFile" => %{
      "clientMutationId" => "123",
      "file" => Map.merge(current_file_info, new_file_info)
      }}, client)
  end

  test "delete a file", context do
    client = context[:client]
    file = context[:existing_file]
    file_id = get_file_id(file)
    file_info = %{
        "filepath" => "testfile3.txt",
        "atime" => "2013-06-05T06:40:25.000000Z",
        "birthtime" => "2013-06-05T06:40:25.000000Z",
        "ctime" => "2013-06-05T06:40:25.000000Z",
        "mode" => 100644,
        "mtime" => "2013-06-05T06:40:25.000000Z",
        "size" => 12
    }
    query = file_id |> delete_file_query()
    assert_data(query, %{"deleteFile" => %{
      "clientMutationId" => "123",
      "file" => file_info
      }}, client)
  end

  test "get a list of file transfers", context do
    client = context[:client]
    file = context[:existing_file]
    file_id = get_file_id(file)
    {:ok, group} = Group.get_by_name(client.name)

    Role.create("admin", :admin, group, group)

    # Create a host
    {:ok, host} = %Host{group: group} |> Host.changeset(%{
      name: "some host",
      transfer_method: "sftp",
      settings: %{
        host: "some.host.edu.au",
        private_key: "AAAAAAAA"
      }
    }) |> Repo.insert
    # Create a destination
    {:ok, _destination} = %Destination{
      host: host,
      source: context[:source]
    } |> Destination.changeset(%{
      base: "/some/base"
    }) |> Repo.insert

    File.update(file, %{}) # Should create file transfer records
    
    host_id = get_host_id(host)
    query = get_file_transfers_for_file_query(file_id)
    assert_data(query, %{
      "node" => %{
        "fileTransfers" => %{
          "edges" => [
            %{
              "node" => %{
                "bytesTransferred" => nil,
                "destination" => %{
                  "base" => "/some/base",
                  "host" => %{
                    "id" => host_id,
                    "transferMethod" => "sftp"
                  },
                  "name" => nil
                },
                "status" => "new"
              }
            }
          ]
        }
      }
    }, client)
  end
end
