defmodule EdmBackend.GraphQL.Context do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case build_context(conn) do
      {:ok, context} ->
        put_private(conn, :absinthe, %{context: context})
      {:error, reason} ->
        send_resp(conn, 403, reason)
      _ ->
        send_resp(conn, 400, "")
    end
  end

  def build_context(conn) do
    {:ok, %{current_resource: Guardian.Plug.current_resource(conn)}}
  end

end
