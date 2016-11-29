defmodule EdmBackend.SourceModelTest do
  require Logger
  use EdmBackend.ModelCase
  alias EdmBackend.Source
  alias EdmBackend.Client

  setup do
    owner = %Client{} |> Client.changeset(%{
      name: "test client",
    })
    {:ok, owner} = Repo.insert owner
    [owner: owner]
  end

  test "valid source values", context do
    valid_source = %Source{} |> Source.changeset(%{
      name: "test source",
      fstype: "POSIX",
      owner_id: context[:owner].id,
    })

    assert valid_source.valid?
  end

  test "invalid source values", context do
    invalid_source = %Source{} |> Source.changeset(%{
      name: "test source",
      owner_id: context[:owner].id,
    })

    assert ! invalid_source.valid?
  end
end
