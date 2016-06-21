defmodule EdmBackend.TokenSigner do
  import Joken
  import Plug.Conn, only: [assign: 3]
  alias EdmBackend.Client
  require Logger

  @doc """
  Adds a signed token to the `conn` map
  """
  def add_token(conn, claims) do
    assign(conn, :token, sign_token(claims))
  end

  def sign_token(%Client{uuid: uuid, ip_address: ip_address}) do
    sign_token(%{uuid: uuid, ip_address: ip_address}, :uploader)
  end

  @doc """
  Signs a JWT for the map of `claims`
  """
  def sign_token(claims) when is_map(claims) do
    claims
      |> token()
      |> with_signer(get_signer)
      |> sign()
      |> get_compact()
  end

  @doc """
  Convenience function that separates out a `role` claim that must be an atom
  and combines it with the rest of the claims.
  """
  def sign_token(claims, role) when is_atom(role) do
    sign_token(Map.put(claims, :role, role))
  end

  @doc """
  Gets the JWT signer. The signature used is the server's secret key.
  """
  def get_signer() do
    hs256(Application.get_env(:edm_backend, EdmBackend.Endpoint)[:secret_key_base])
  end

  @doc """
  Constructs a Joken claims struct that can be used with the `Joken.Plug`
  validation function.
  """
  def require_claims(token, [{claim, value} | other_claims]) when is_atom(claim) do
    token
      |> Joken.with_validation(Atom.to_string(claim), &(&1 == value))
      |> require_claims(other_claims)
  end

  def require_claims(token, []) do
    token
      |> Joken.with_signer(get_signer())
      |> with_json_module(Poison)
  end

end