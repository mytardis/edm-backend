defmodule EdmBackend.FileMutationTest do
  require Logger
  use EdmBackend.GraphQLCase
  alias EdmBackend.Repo
  alias EdmBackend.Client
  alias EdmBackend.Source
  alias EdmBackend.File

  setup do
    {:ok, owner} = %Client{} |> Client.changeset(%{
      name: "test client",
    }) |> Repo.insert

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

  defp create_or_update_file_query(file_info, source_id) do

    file_info_json = Poison.encode!(file_info)

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
            }
        }
    }",
"variables": {
  "input": {
    "clientMutationId": "123",
    "sourceId": "#{source_id}",
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

  defp get_source_id(source) do
    Absinthe.Relay.Node.to_global_id(:source, source.id, EdmBackend.GraphQL.Schema)
  end

  defp get_file_id(file) do
    Absinthe.Relay.Node.to_global_id(:file, file.id, EdmBackend.GraphQL.Schema)
  end

  test "creating a file", context do
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

    query = file_info |> create_or_update_file_query(get_source_id(context[:source]))
    assert_errors(query, [%{locations: [%{column: 0, line: 2}],
      message: "In field \"createOrUpdateFile\": Not logged in"}])
    assert_data(query, %{"createOrUpdateFile" => %{
      "clientMutationId" => "123",
      "file" => file_info,
       }}, client)
  end

  test "update a file", context do
    client = context[:client]

    # This file should not exist
    file_info = %{
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
      "file" => Map.merge(file_info, new_file_info)
      }}, client)
  end
end
