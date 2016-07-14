# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config
import Logger

# General application configuration
config :edm_backend,
  ecto_repos: [EdmBackend.Repo]

# Configures the endpoint
config :edm_backend, EdmBackend.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tafOjA8acApntV2jbrOWlcEcPIR2BCVaLz4Z9Q5UlvgMoNYvx8jj9GHUgkyTg7Uk",
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
  schema_module: TestSchema,
  schema_json_path: "#{Path.dirname(__DIR__)}/priv/graphql"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

Logger.debug "Loading secrets if present"
if File.exists?("#{Path.dirname(__DIR__)}/config/#{Mix.env}.secret.exs") do
  import_config "#{Mix.env}.secret.exs"
  Logger.debug "Secrets loaded."
else
  Logger.debug "No secrets found, skipping."
end
