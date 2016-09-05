%{
  edm_backend: %{
    EdmBackend.Endpoint => [secret_key_base:
      {:flasked, :SECRET_KEY, :string, "tafOjA8acApntV2jbrOWlcEcPIR2BCVaLz4Z9Q5UlvgMoNYvx8jj9GHUgkyTg7Uk"}],
  },

  ueberauth: %{
    # Set client_id, client_secret, redirect_uri
    Ueberauth.Strategy.EDM.OAuth => [
      client_id: {:flasked, :EDM_OAUTH_CLIENT_ID, :string},
      client_secret: {:flasked, :EDM_OAUTH_CLIENT_SECRET, :string},
      redirect_uri: {:flasked, :EDM_OAUTH_REDIRECT_URI, :string},
      discovery_url: {:flasked, :EDM_OAUTH_DISCOVERY_URL, :string}
    ]
  }
}
