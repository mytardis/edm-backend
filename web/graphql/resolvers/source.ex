defmodule EdmBackend.GraphQL.Resolver.Source do
  import Canada, only: [can?: 2]
  alias EdmBackend.Repo
  alias EdmBackend.Source
  alias EdmBackend.Client

  def list(client = %Client{}, viewer) do
    all_sources = for source <- client |> Source.all_sources do
      if viewer |> can?(view(source)) do
        source
      end
    end
    {:ok, all_sources}
  end

  def list(_args, viewer) do
    all_sources = for source <- Source |> Repo.all do
      if viewer |> can?(view(source)) do
        source
      end
    end
    {:ok, all_sources}
  end

  def find(%{id: id}, viewer) do
    case Repo.get(Source, id) do
      nil -> {:error, "Source not found"}
      source ->
        if viewer |> can?(view(source)) do
          {:ok, source}
        else
          {:error, "Unauthorised to view source"}
        end
    end
  end

  def find(client = %Client{}, name, viewer) do
    case Source.find(client, name) do
      {:ok, source} ->
        if viewer |> can?(view(source)) do
          {:ok, source}
        else
          {:error, "Unauthorised to view source"}
        end
      {:error, error} ->
        {:error, error}
    end
  end

  def get_or_create(client, source_info, viewer) do
    if viewer |> can?(update(client)) do
      Source.get_or_create(client, source_info)
    else
      {:error, "Unauthorised to create or update source"}
    end
  end
end
