defmodule EdmBackend.Plug.TokenAuth do
  @moduledoc """
  Protects API endpoints that require JWT auth, optionally invoking `:on_failure`
  if authentication fails. The default is to return "Unauthorized" HTTP 401.
  """

  import Joken
  import Plug.Conn
  alias EdmBackend.TokenSigner
  require Logger

  def init(opts) do
    required_claims = Keyword.fetch!(opts, :claims)
    require_ip_match = Keyword.get(opts, :require_ip_match, true)
    on_failure = Keyword.get(opts, :on_failure, &EdmBackend.Plug.TokenAuth.unauthorised/1)

    {required_claims, require_ip_match, on_failure}
  end

  def call(conn, {required_claims, require_ip_match, on_failure}) do

    # JWT claims are injected during testing or explicitly disabled. This code
    # skips token verification in this case.
    cond do
      Map.get(conn.private, :token_auth_skip, false) ->
        conn

      claims = conn.assigns[:claims] ->
        Logger.debug "Skipping JWT verification; claims already provided."
        conn

      true ->
        Logger.debug "Verifying JWT..."
        jwt_token = conn
          |> get_token_from_header
          |> require_claims(required_claims)
        if require_ip_match do
          jwt_token = jwt_token |> require_claims([{:ip_address, conn.assigns[:remote_ip]} | required_claims])
        else
          jwt_token = jwt_token |> require_claims(required_claims)
        end
        jwt_token = jwt_token |> verify

        case jwt_token do
          %{claims: claims, error: error} when claims == %{} ->
            Logger.debug "Error: " <> error
            conn |> on_failure.() |> halt # No claims means no auth
          %{claims: claims} ->
            Logger.debug "Valid token"
            Logger.debug inspect(claims)
            conn |> assign(:claims, claims)
        end
    end
  end

  def unauthorised(conn) do
    conn |> send_resp(401, "Unauthorized")
  end

  defp get_token_from_header(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        token |> token
      _ ->
        %Joken.Token{}
    end
  end

  defp require_claims(token, [{claim, value} | other_claims]) when is_atom(claim) do
    token
      |> Joken.with_validation(Atom.to_string(claim), &(&1 == value))
      |> require_claims(other_claims)
  end

  defp require_claims(token, []) do
    token
      |> Joken.with_signer(TokenSigner.get_signer())
      |> with_json_module(Poison)
  end
end