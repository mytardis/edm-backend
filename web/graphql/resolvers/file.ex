defmodule EdmBackend.GraphQL.Resolver.File do
  import Canada, only: [can?: 2]
  alias Absinthe.Relay
  alias EdmBackend.Repo
  alias EdmBackend.File

  def list(args, source, viewer) do
    if viewer |> can?(view(source)) do
      {:ok, source |> File.get_file_query |> Relay.Connection.from_query(&Repo.all/1, args)}
    else
      {:error, "Unauthorised to view transfers for file"}
    end
  end

  def find(%{id: id}, viewer) do
    case Repo.get(File, id) do
      nil -> {:error, "File not found"}
      file ->
        if viewer |> can?(view(file)) do
          {:ok, file}
        else
          {:error, "Unauthorised to view file"}
        end
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

  def create_or_update(source, file, viewer) do
    if viewer |> can?(create(source)) and viewer |> can?(update(source)) do
      File.create_or_update(source, file)
    else
      {:error, "Unauthorised to create or update file in source"}
    end
  end

  def update(source, file, viewer) do
    if viewer |> can?(update(source)) do
      File.update(source, file)
    else
      {:error, "Unauthorised to update file in source"}
    end
  end

  def delete(client, file, viewer) do
    # TODO implement this function
  end

end
