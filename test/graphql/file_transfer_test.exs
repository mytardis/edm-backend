defmodule EdmBackend.GraphQLFileTransferTest do
  @moduledoc """
  Testing File Transfer queries and mutations

  """
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
  alias EdmBackend.FileTransfer

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

  defp get_pending_file_transfers_for_destination_query(dest_id, amount, status) do
    """
{"query": "query getPendingFileTransfers($destId: String, $amount: Int, $status: String) {
     currentClient {
         destination(id: $destId) {
             base
             id
             host {
                 name
                 transferMethod
             }
             fileTransfers(first: $amount, status: $status) {
                 edges {
                     node {
                         status
                     }
                 }
             }
         }
     }
 }",
 "variables": {
     "destId": "#{dest_id}",
     "amount": #{amount},
     "status": "#{status}"
 }
}
"""
  end

  defp update_file_transfer_query(id, new_data) when is_map(new_data) do
    file_transfer_data_json = Poison.encode!(new_data)
    """
{"query": "mutation updateFileTransfer($input: FileTransferInputObject!) {
  updateFileTransfer(input: $input) {
            clientMutationId
            fileTransfer {
              status
              bytesTransferred
            }
        }
    }",
"variables": {
  "input": {
    "clientMutationId": "123",
    "id": "#{id}",
    "fileTransfer": #{file_transfer_data_json}
  }
}
}
    """
  end

  defp get_source_id(source) do
    Absinthe.Relay.Node.to_global_id(
      :source, source.id, EdmBackend.GraphQL.Schema)
  end

  defp get_client_id(client) do
    Absinthe.Relay.Node.to_global_id(
      :client, client.id, EdmBackend.GraphQL.Schema)
  end

  defp get_file_id(file) do
    Absinthe.Relay.Node.to_global_id(:file, file.id, EdmBackend.GraphQL.Schema)
  end

  defp get_host_id(host) do
    Absinthe.Relay.Node.to_global_id(:host, host.id, EdmBackend.GraphQL.Schema)
  end

  defp get_file_transfer_id(file_transfer) do
    Absinthe.Relay.Node.to_global_id(
      :file_transfer, file_transfer.id, EdmBackend.GraphQL.Schema)
  end

  test "get a list of pending file transfers", context do
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
    {:ok, destination} = %Destination{
      host: host,
      source: context[:source]
    } |> Destination.changeset(%{
      base: "/some/base"
    }) |> Repo.insert

    File.update_transfers(file) # Should create file transfer records

    dest_relay_id = Absinthe.Relay.Node.to_global_id(
      :destination, destination.id, EdmBackend.GraphQL.Schema)
    query = get_pending_file_transfers_for_destination_query(destination.id, 10, "new")
    assert_data(query, %{
      "currentClient" => %{
        "destination" => %{
          "base" => "/some/base",
          "id" => dest_relay_id,
          "fileTransfers" => %{
            "edges" => [
              %{
                "node" => %{
                  "status" => "new"
                },
              },
            ],
          },
          "host" => %{
            "name" => "some host",
            "transferMethod" => "sftp"
          },
        },
      },
    }, client)
  end

  test "update a file transfer", context do
    client = context[:client]
    file = context[:existing_file]
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

    # Get the first FileTransfer records
    [file_transfer|_] = FileTransfer.get_transfers_for_file(file)
    file_transfer_id = get_file_transfer_id(file_transfer)
    query = update_file_transfer_query(file_transfer_id, %{
      status: "abc",
      bytes_transferred: 50
    })

    assert_errors(query, [%{locations: [%{column: 0, line: 2}],
      message: "In field \"updateFileTransfer\": Not logged in"}])

    assert_data(query, %{
      "updateFileTransfer" => %{
        "clientMutationId" => "123",
        "fileTransfer" => %{
          "bytesTransferred" => 50,
          "status" => "abc"
        }
      }
    }, client)
  end
end
