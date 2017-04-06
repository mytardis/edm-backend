use Mix.Config

# Configure flasked for environment-based config
config :flasked,
  otp_app: :edm_backend,
  map_file: "priv/flasked/flasked_test.exs"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :edm_backend, EdmBackend.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :edm_backend, EdmBackend.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  url: "ecto://root@localhost/edm_backend_test"
