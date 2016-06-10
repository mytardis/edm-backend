use Mix.Config

secret_key = System.get_env("secret_key")
if is_nil(secret_key) do
  raise "You must set a \"secret_key\" environment variable!"
end

config :edm_backend, EdmBackend.Endpoint,
  secret_key_base: secret_key

# Configure your database
config :edm_backend, EdmBackend.Repo,
    adapter: Ecto.Adapters.Postgres,
    hostname: System.get_env("db_host") || "db",
    username: System.get_env("db_username") || "postgres",
    password: System.get_env("db_password") || "postgres",
    database: System.get_env("db_name") || "edm_backend_prod",
    pool_size: System.get_env("db_pool_size") || 20
