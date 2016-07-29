%{
  edm_backend: %{
    EdmBackend.Endpoint => [secret_key_base:
      {:flasked, :SECRET_KEY, :string, "tafOjA8acApntV2jbrOWlcEcPIR2BCVaLz4Z9Q5UlvgMoNYvx8jj9GHUgkyTg7Uk"}],

    # Set client_id, client_secret, redirect_uri
    Ueberauth.Strategy.Google.OAuth => {:flasked, :GOOGLE_OAUTH_CONFIG, :dict, %{}}
  }
}
