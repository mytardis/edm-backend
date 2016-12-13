defmodule EdmBackend.FileMutationTest do
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

  test "creating a file", context do
    client = context[:client]
    file_info = %{
        "filepath" => "testfile3.txt",
        "atime" => "2013-06-05T06:40:25.000Z",
        "birthtime" => "2013-06-05T06:40:25.000Z",
        "ctime" => "2013-06-05T06:40:25.000Z",
        "mode" => 100644,
        "mtime" => "2013-06-05T06:40:25.000Z",
        "size" => 12
       }
    file_info_json = Poison.encode!(file_info)
    query = """
{"query": "mutation getOrCreateFile($input: GetOrCreateFileInput!) {
  getOrCreateFile(input: $input) {
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
    assert_errors(query, [%{locations: [%{column: 0, line: 2}],
      message: "Field `getOrCreateFile': Not logged in"}])
    assert_data(query, %{"getOrCreateFile" => %{
      "clientMutationId" => "123",
      "file" => file_info,
       }}, client)
  end
end
