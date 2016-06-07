defmodule EdmBackend.PageController do
  use EdmBackend.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
