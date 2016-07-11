use Mix.Config

# Configure your database
config :edm_backend, EdmBackend.Repo,
    adapter: Ecto.Adapters.Postgres,
    hostname: System.get_env("db_host") || "db",
    username: System.get_env("db_username") || "postgres",
    password: System.get_env("db_password") || "postgres",
    database: System.get_env("db_name") || "edm_backend_prod",
    pool_size: System.get_env("db_pool_size") || 20

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
  redirect_uri: System.get_env("GOOGLE_REDIRECT_URI")
