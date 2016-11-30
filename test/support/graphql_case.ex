defmodule EdmBackend.GraphQLCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias EdmBackend.Client
      alias EdmBackend.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import EdmBackend.ModelCase

      defp _run_query(query, client \\ nil) do
        {query, variables} = case Poison.decode(query) do
          {:ok, %{"query" => decoded_query, "variables" => variables}} ->
            {decoded_query, variables}
          {:ok, %{"query" => decoded_query}} ->
            {decoded_query, %{}}
          {:error, _} ->
            {query, %{}}
        end
        {:ok, result} = case client do
          nil ->
            Absinthe.run(query, EdmBackend.GraphQL.Schema,
              variables: variables)
          _ ->
            Absinthe.run(query, EdmBackend.GraphQL.Schema,
              context: %{current_resource: %Client{} = client},
              variables: variables)
        end
        case result do
          %{errors: errors} ->
            {:ok, %{errors: errors, data: %{}}}
          %{errors: errors, data: data} ->
            {:ok, %{errors: errors, data: data}}
          %{data: data} ->
            {:ok, %{data: data}}
        end
      end

      defp assert_data(query, data) do
        assert {:ok, %{data: data}} == _run_query(query)
      end

      defp assert_data(query, data, client) do
        assert {:ok, %{data: data}} == _run_query(query, client)
      end

      defp assert_errors(query, errors) do
        assert {:ok, %{errors: errors, data: %{}}} == _run_query(query)
      end

      defp assert_errors(query, errors, client) do
        assert {:ok, %{error: errors, data: %{}}} == _run_query( query, client)
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EdmBackend.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(EdmBackend.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  Helper for returning list of errors in a struct when given certain data.

  ## Examples

  Given a User schema that lists `:name` as a required field and validates
  `:password` to be safe, it would return:

      iex> errors_on(%User{}, %{password: "password"})
      [password: "is unsafe", name: "is blank"]

  You could then write your assertion like:

      assert {:password, "is unsafe"} in errors_on(%User{}, %{password: "password"})

  You can also create the changeset manually and retrieve the errors
  field directly:

      iex> changeset = User.changeset(%User{}, password: "password")
      iex> {:password, "is unsafe"} in changeset.errors
      true
  """
  def errors_on(struct, data) do
    struct.__struct__.changeset(struct, data)
    |> Ecto.Changeset.traverse_errors(&EdmBackend.ErrorHelpers.translate_error/1)
    |> Enum.flat_map(fn {key, errors} -> for msg <- errors, do: {key, msg} end)
  end
end
