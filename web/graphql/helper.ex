defmodule EdmBackend.GraphQL.Helper do
  alias EdmBackend.Client

  @doc "Extracts the viewer client struct from the GraphQL context"
  defmacro get_viewer(viewer) do
    quote do
      %{
        context: %{current_resource: %Client{} = unquote(viewer)}
      }
    end
  end

  @doc "Extracts the viewer and source from the GraphQL context"
  defmacro get_viewer_and_source(viewer, source) do
    quote do
      %{
        context: %{current_resource: %Client{} = unquote(viewer)},
        source: unquote(source)
      }
    end
  end
end
