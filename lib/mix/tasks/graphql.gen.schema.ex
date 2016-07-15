defmodule Mix.Tasks.Graphql.Gen.Schema do
  @moduledoc """
  Updates GraphQL schema.json file.
  """

  use Mix.Task

  @doc false
  def run(_args) do
    GraphQL.Relay.generate_schema_json!
    System.cmd("#{Path.expand("../../../",__DIR__)}/node_modules/brunch/bin/brunch", ["build"])
  end
end
