defmodule EdmBackend.AuthController do
  use EdmBackend.Web, :controller

  plug Ueberauth

  alias EdmBackend.UserFromAuth
  import Logger

  @supported_oauth_response_types ~w(token)

  defp get_default_provider() do
    [default_provider|_] = Application.get_env(:ueberauth, Ueberauth)
                              |> Keyword.get(:providers)
                              |> Keyword.keys
    default_provider |> Atom.to_string
  end

  def request(conn, params) do
    params = params |> Map.put("provider", get_default_provider)
    conn |> redirect(to: auth_path(conn, :request, get_default_provider, params))
  end

  def api_request(%{query_params: %{
      "client_id" => client_id,
      "redirect_uri" => redirect_uri,
      "response_type" => response_type
    } = query_params} = conn, params) do

      provider = case params do
        %{"provider" => p} -> p
        _ -> get_default_provider
      end

      oauth_request = %{
        client_id: client_id,
        redirect_uri: redirect_uri,
        state: Map.get(query_params, "state", nil),
        response_type: response_type
      }

      if (Enum.member?(@supported_oauth_response_types, response_type)) do
        case validate_oauth_client(client_id, redirect_uri) do
          {:ok} ->
            conn |> put_session(:signin_oauth2, oauth_request)
                 |> redirect(to: auth_path(conn, :request, provider))
          {:error, reason} ->
            conn |> json(%{error: reason})
        end
      else
        conn |> json(%{error: "Unsupported response type; supported types are: " <> Enum.join(@supported_oauth_response_types, ", ")})
      end
  end

  def api_request(conn, _) do
    conn |> json(%{error: "client_id, redirect_uri and response_type are required"})
  end

  def validate_oauth_client(client_id, redirect_uri) do
    # PUT REAL CLIENT CHECKING LOGIC HERE
    case {client_id, redirect_uri} do
      {"valid_client", "https://example.com/"} ->
        {:ok}
      {"valid_client", _} ->
        {:error, "invalid redirect_uri"}
      _ ->
        {:error, "invalid client id"}
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn |> render_signin_failure("Failed to authenticate.")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    redirect = Map.get(params, "state", "/")
    case UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        conn |> render_signing_success(user, redirect)
      {:error, reason} ->
        conn |> render_signin_failure(reason, redirect)
    end
  end

  defp render_signing_success(conn, user, redirect \\ "/") do
    conn = conn |> fetch_flash
    {:ok, conn, jwt, oauth_params} = case get_session(conn, :signin_oauth2) do
      nil ->
        {:ok, conn, nil, nil}
      oauth_params ->
        conn = conn |> delete_session(:signin_oauth2)
                    |> Guardian.Plug.api_sign_in(user)
        {:ok, conn, Guardian.Plug.current_token(conn), oauth_params}
    end

    case oauth_params do
      nil ->
        try do
          conn
          |> Guardian.Plug.sign_in(user)
          |> put_flash(:info, "Logged in as #{user.name}")
          |> redirect(to: redirect)
        rescue
          ArgumentError ->
            conn |> render_signing_success(user)
        end
      %{response_type: "token"} ->
        conn |> oauth_implicit_redirect(oauth_params, jwt)
    end
  end

  defp render_signin_failure(conn, reason, redirect \\ "/") do
    case get_session(conn, :signin_oauth2) do
      nil ->
        try do
          conn
          |> put_flash(:error, reason)
          |> redirect(to: redirect)
        rescue
          _ ->
            conn |> render_signin_failure(reason)
        end
      %{redirect_uri: redirect_uri, response_type: "token"} ->
        conn |> delete_session(:signin_oauth2)
             |> redirect(external: redirect_uri <> "#error="<>URI.encode(reason))
    end
  end

  defp oauth_implicit_redirect(conn, %{redirect_uri: redirect_uri, state: state}, token) do
    Logger.debug("!!!!!!!!!!!!!!!!!!!!!!!!!")
    Logger.debug inspect(token)
    redirect_uri = redirect_uri <> "#access_token=" <> URI.encode(token) <> "&token_type=Bearer"
    case state do
      nil ->
        conn |> redirect(external: redirect_uri)
      _ ->
        conn |> redirect(external: redirect_uri <> "&state=" <> URI.encode(state))
    end
  end

  def refresh_token(conn, _params) do
    token = conn |> Guardian.Plug.current_token
    case token |> Guardian.refresh! do
      {:ok, jwt, _claims} ->
        conn |> put_resp_header("authorization", "Bearer " <> jwt)
             |> json(%{token: "Bearer " <> jwt})
      _ ->
        conn |> json(%{error: "Could not refresh the access token"})
    end

  end

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

end
