defmodule EdmBackend.CurrentClientTest do
  use EdmBackend.GraphQLCase
  alias EdmBackend.Client

  setup do
    owner = %Client{} |> Client.changeset(%{
      name: "test client",
    })
    {:ok, owner} = Repo.insert owner
    [client: owner]
  end

  test "current client authentication", context do
    client = context[:client]
    query = """
    query currentClient {
      currentClient {
        name
      }
    }
    """
    assert_errors(query, [%{locations: [%{column: 0, line: 2}],
                            message: "Field `currentClient': Not logged in"}])
    assert_data(query, %{"currentClient" => %{"name" => "test client"}}, client)
  end


end
