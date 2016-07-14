use Mix.Config

import_config "env_config.exs"

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :edm_backend, EdmBackend.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../", __DIR__)],
             mix: ["eye_drops", cd: Path.expand("../", __DIR__)]]


# Watch static and templates for browser reloading.
config :edm_backend, EdmBackend.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Update the graphql schema json file
config :eye_drops,
  tasks: [
    %{
      id: :graphql_update_schema,
      name: "Update GraphQL Schema",
      cmd: "mix graphql.gen.schema",
      paths: ["web/graphql/*"] # path to graphql files
    }
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :edm_backend, EdmBackend.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "edm_backend_dev",
  hostname: System.get_env("db_host") || "localhost",
  pool_size: 10
