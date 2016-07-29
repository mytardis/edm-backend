# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config
import Logger

# Configure flasked for environment-based config
config :flasked,
  otp_app: :edm_backend,
  map_file: "priv/flasked_env.exs"

# General application configuration
config :edm_backend,
  ecto_repos: [EdmBackend.Repo]

# Configures the endpoint
config :edm_backend, EdmBackend.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: EdmBackend.ErrorView, accepts: ~w(html json)],
  pubsub: [name: EdmBackend.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ueberauth, Ueberauth,
  providers: [ google: { Ueberauth.Strategy.Google, [] } ]

config :graphql_relay,
  schema_module: EdmBackend.GraphQL.Schema,
  schema_json_path: "#{Path.dirname(__DIR__)}/priv/graphql"

# Global database config
config :edm_backend, EdmBackend.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: {:system, "DATABASE_URL"}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
