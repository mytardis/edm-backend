defmodule EdmBackend.FileMutationTest do
  use EdmBackend.GraphQLCase
  alias EdmBackend.Client
  alias EdmBackend.Source

  setup do
    owner = %Client{} |> Client.changeset(%{
      name: "test client",
    })
    {:ok, owner} = Repo.insert owner
    source = %Source{} |> Source.changeset(%{
      name: "test source",
      fstype: "POSIX",
      owner_id: owner.id,
    })
    {:ok, source} = Repo.insert source
    [client: owner, source: source]
  end

  test "creating a file", context do
    client = context[:client]
    query = """
{"query": "mutation getOrCreateFile($input: GetOrCreateFileInput!) {
  getOrCreateFile(input: $input) {
            clientMutationId
            file {
            	filepath
            }
        }
    }",
"variables": {
  "input": {
    "clientMutationId": "123",
    "source": {"name": "test source"},
    "file": {
      "filepath": "testfile3.txt",
        "size": 12,
        "mtime": "2013-06-05T06:40:25.000Z",
      "atime": "2013-06-05T06:40:25.000Z",
      "ctime": "2013-06-05T06:40:25.000Z",
      "birthtime": "2013-06-05T06:40:25.000Z",
      "mode": 100644
    }
  }
}
}
    """
    assert_errors(query, [%{locations: [%{column: 0, line: 2}],
      message: "Field `getOrCreateFile': Not logged in"}])
    assert_data(query, %{"getOrCreateFile" => %{
      "clientMutationId" => "123",
      "file" => %{"filepath" => "testfile3.txt"}}}, client)
  end
end
