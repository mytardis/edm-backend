use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :edm_backend, EdmBackend.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :edm_backend, EdmBackend.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "edm_backend_test",
  hostname: "db",
  pool: Ecto.Adapters.SQL.Sandbox
