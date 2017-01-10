defmodule EdmBackend.FileMutationTest do
  require Logger
  use EdmBackend.GraphQLCase
  alias EdmBackend.Client
  alias EdmBackend.Source

  setup do
    owner = %Client{} |> Client.changeset(%{
      name: "test client",
    })
    {:ok, owner} = Repo.insert owner
    source = %Source{owner: owner} |> Source.changeset(%{
      name: "test source",
      fstype: "POSIX"
    })
    {:ok, source} = Repo.insert source
    [client: owner, source: source]
  end

  defp create_or_update_file_query(file_info) do
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
    "source": {"name": "test source"},
    "file": #{file_info_json}
  }
}
}
    """
  end

  defp update_file_query(file_info) do
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
    "clientMutationId": "123",
    "source": {"name": "test source"},
    "file": #{file_info_json}
  }
}
}
    """
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
    query = file_info |> create_or_update_file_query
    assert_errors(query, [%{locations: [%{column: 0, line: 2}],
      message: "Field `createOrUpdateFile': Not logged in"}])
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
    query = file_info |> update_file_query
    assert_errors(query, [%{locations: [%{column: 0, line: 2}],
      message: "Field `updateFile': Not logged in"}])
    assert_errors(query, [%{locations: [%{column: 0, line: 2}],
      message: "Field `updateFile': File does not exist"}], client)

    # Now create the file...
    query = file_info |> create_or_update_file_query
    {:ok, _result} = query |> EdmBackend.GraphQLCase.run_query(client)

    # Update the file...
    new_file_info = %{
        "filepath" => "testfile4.txt",
        "mode" => 100777,
        "size" => 120
    }
    query = new_file_info |> update_file_query

    # Confirm that the updated file contains the updated parameters
    assert_data(query, %{"updateFile" => %{
      "clientMutationId" => "123",
      "file" => Map.merge(file_info, new_file_info)
      }}, client)
  end
end
