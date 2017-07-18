defmodule EdmBackend.GraphQL.Resolver.File do
  import Canada, only: [can?: 2]
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.File
  alias EdmBackend.Resolver.Source

  def list(args, source, viewer) do
    if viewer |> can?(view(source)) do
      {:ok, source |> File.get_file_query
                   |> Relay.Connection.from_query(&Repo.all/1, args)}
    else
      {:error, "Unauthorised to view transfers for file"}
    end
  end

  def find(%{id: id}) do
    case Repo.get(File, id) do
      nil -> {:error, "File not found"}
      file -> {:ok, file}
    end
  end

  def find(%{id: id}, viewer) do
    case find(%{id: id}) do
      {:ok, file} ->
        if viewer |> can?(view(file)) do
          {:ok, file}
        else
          {:error, "Unauthorised to view file"}
        end
      {:error, error} -> {:error, error}
    end
  end

  def find(source, filepath, viewer) do
    query = source |> File.get_file_query(%{filepath: filepath})
    case Repo.one(query) do
      nil -> {:error, "File not found"}
      file ->
        if viewer |> can?(view(file)) do
          {:ok, file}
        else
          {:error, "Unauthorised to view file"}
        end
    end
  end

  def from_global_id(global_id, viewer \\ nil) do
    case Absinthe.Relay.Node.from_global_id(
        global_id, EdmBackend.GraphQL.Schema) do
      {:ok, %{type: :file, id: id}} ->
        case viewer do
          nil ->
            find(%{id: id})
          v ->
            find(%{id: id}, v)
        end
      {:ok, %{type: _, id: id}} ->
        {:error, "Invalid ID"}
      {:error, error} -> {:error, error}
    end
  end

  def create_or_update(client, file, source_info, viewer) do
    case EdmBackend.GraphQL.Resolver.Source.get_or_create(
        client, source_info, viewer) do
      {:ok, source} ->
        case create_or_update(source, file, viewer) do
          {:ok, file} ->
            {:ok, %{file: file}}
          {:error, error} -> {:error, error}
        end
      {:error, error} -> {:error, error}
    end
  end

  defp create_or_update(source, file, viewer) do
    if viewer |> can?(create(source)) and viewer |> can?(update(source)) do
      File.create_or_update(source, file)
    else
      {:error, "Unauthorised to create or update file in source"}
    end
  end

  def update(file, file_info, viewer) do
    if viewer |> can?(update(file)) do
      File.update(file, file_info)
    else
      {:error, "Unauthorised to update file in source"}
    end
  end

  def get_source(file, viewer) do
    source = file |> Repo.preload(:source) |> Map.get(:source)
    if viewer |> can?(view(source)) do
      {:ok, source}
    else
      {:error, "Unauthorised to view source for file"}
    end
  end

  def delete(file, viewer) do
    if viewer |> can?(delete(file)) do
      file |> Repo.delete
    else
      {:error, "Unauthorised to delete file"}
    end
  end

end
