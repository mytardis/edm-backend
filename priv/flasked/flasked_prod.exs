%{
  edm_backend: %{
    EdmBackend.Endpoint => [
      secret_key_base: {:flasked, :SECRET_KEY, :string, "tafOjA8acApntV2jbrOWlcEcPIR2BCVaLz4Z9Q5UlvgMoNYvx8jj9GHUgkyTg7Uk"},
    ]
  },

  ueberauth: %{
    # Set client_id, client_secret, redirect_uri
    Ueberauth.Strategy.EDM.OAuth => [
      client_id: {:flasked, :EDM_OAUTH_CLIENT_ID, :string},
      client_secret: {:flasked, :EDM_OAUTH_CLIENT_SECRET, :string},
      discovery_url: {:flasked, :EDM_OAUTH_DISCOVERY_URL, :string}
    ]
  },

  guardian: %{
    Guardian => [
      allowed_algos: {:flasked, :GUARDIAN_ALLOWED_ALGOS, :list, ["HS512"]},
      secret_key: {:flasked, :GUARDIAN_SECRET_KEY, :string, "tafOjA8acApntV2jbrOWlcEcPIR2BCVaLz4Z9Q5UlvgMoNYvx8jj9GHUgkyTg7Uk"}
    ]
  }
}
