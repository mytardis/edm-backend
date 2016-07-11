defmodule EdmBackend.AuthController do
  import Logger
  use EdmBackend.Web, :controller

  plug Ueberauth

  alias Ueberauth.Strategy.Helpers
  alias EdmBackend.UserFromAuth

  def request(conn, _params) do
    conn |> render("request.html", callback_url: Helpers.callback_url(conn))
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        Logger.debug inspect(user)
        conn
        |> put_flash(:info, "Successfully authenticated as " <> user.name)
        |> put_session(:current_user, user)
        |> redirect(to: "/")
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

end
