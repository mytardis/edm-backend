# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config
require Logger


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
  providers: [
    edm_auth: { Ueberauth.Strategy.EDM, [] }
  ]

config :guardian, Guardian,
  verify_module: Guardian.JWT,
  issuer: "edm-backend",
  ttl: {30, :days},
  verify_issuer: true,
  serializer: EdmBackend.GuardianSerialiser,
  hooks: GuardianDb

config :guardian_db, GuardianDb,
  repo: EdmBackend.Repo,
  sweep_interval: 120 # 120 minutes

# Global database config
config :edm_backend, EdmBackend.Repo,
  adapter: String.to_atom(System.get_env("DATABASE_ADAPTER") || "Elixir.Ecto.Adapters.MySQL"),
  url: {:system, "DATABASE_URL"}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
