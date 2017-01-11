defmodule EdmBackend.AuthController do
  require Logger
  use EdmBackend.Web, :controller
  alias EdmBackend.ClientFromAuth

  plug Ueberauth

  @supported_oauth_response_types ~w(token)

  # This returns the first auth provider in the ueberauth config
  defp get_default_provider() do
    [default_provider|_] = Application.get_env(:ueberauth, Ueberauth)
                              |> Keyword.get(:providers)
                              |> Keyword.keys
    default_provider |> Atom.to_string
  end

  @doc """
  Request function executed only if ueberauth does not intercept the request.
  This occurs if the authentication provider is invalid or not specified, and
  will redirect to the default auth provider.
  """
  def request(conn, params) do
    params = params |> Map.put("provider", get_default_provider())
    conn |> redirect(to: auth_path(conn, :request, get_default_provider(), params))
  end

  @doc """
  This function is executed when performing authentication for API access, via
  an OAuth2 flow. OAuth2 parameters are stored in the session for use once the
  callback endpoint is triggered by the OAuth2 server.
  """
  def api_request(%{query_params: %{
      "client_id" => client_id,
      "redirect_uri" => redirect_uri,
      "response_type" => response_type
    } = query_params} = conn, params) do

      provider = case params do
        %{"provider" => p} -> p
        _ -> get_default_provider()
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

  @doc """
  This function is called if an API authentication request is triggered with
  missing parameters.
  """
  def api_request(conn, _) do
    conn |> json(%{error: "client_id, redirect_uri and response_type are required"})
  end

  @doc """
  Validates the client id and redirect URI
  """
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

  @doc """
  OAuth2 callback function called when the authentication has failed
  """
  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn |> render_signin_failure("Failed to authenticate.")
  end

  @doc """
  OAuth2 callback function called when the authentication is successful
  """
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    redirect = Map.get(params, "state", "/")
    case ClientFromAuth.find_or_create(auth) do
      {:ok, client} ->
        conn |> render_signing_success(client, redirect)
      {:error, reason} ->
        conn |> render_signin_failure(reason, redirect)
    end
  end

  # Renders a successful signin attempt, either by redirecting to the third-party
  # app in the case of API authentication, or to the internal route for standard
  # auth.
  defp render_signing_success(conn, client, redirect \\ "/") do
    conn = conn |> fetch_flash
    {:ok, conn, jwt, oauth_params} = case get_session(conn, :signin_oauth2) do
      nil ->
        {:ok, conn, nil, nil}
      oauth_params ->
        conn = conn |> delete_session(:signin_oauth2)
                    |> Guardian.Plug.api_sign_in(client)
        {:ok, conn, Guardian.Plug.current_token(conn), oauth_params}
    end

    case oauth_params do
      nil ->
        try do
          conn
          |> Guardian.Plug.sign_in(client)
          |> put_flash(:info, "Logged in as #{client.name}")
          |> redirect(to: redirect)
        rescue
          ArgumentError ->
            conn |> render_signing_success(client)
        end
      %{response_type: "token"} ->
        conn |> oauth_implicit_redirect(oauth_params, jwt)
    end
  end

  # Renders a failure message if the authentication fails
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

  # Performs an OAuth2 implicit auth redirect, where the token is encoded in the
  # URL fragment.
  defp oauth_implicit_redirect(conn, %{redirect_uri: redirect_uri, state: state}, token) do
    redirect_uri = redirect_uri <> "#access_token=" <> URI.encode(token) <> "&token_type=Bearer"
    case state do
      nil ->
        conn |> redirect(external: redirect_uri)
      _ ->
        conn |> redirect(external: redirect_uri <> "&state=" <> URI.encode(state))
    end
  end

  @doc """
  Renews the current token used for API auth
  """
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

  @doc """
  Invalidates the current session
  """
  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

end
