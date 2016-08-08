defmodule EdmBackend.GraphQL.Schema.Root do
  alias GraphQL.Schema
  alias GraphQL.Type.ObjectType
  alias GraphQL.Type.String
  alias GraphQL.Relay.Node
  alias GraphQL.Relay.Connection
  alias EdmBackend.GraphQL.Schema.Client
  alias EdmBackend.Repo
  import Logger

  import Ecto.Query

  def node_interface do
    Node.define_interface(fn(obj) ->
      EdmBackend.GraphQL.Schema.Client.type
    end)
  end

  def node_field do
    Node.define_field(node_interface, fn (_item, args, _ctx) ->
      [type, id] = Node.from_global_id(args[:id])
      case type do
        "client" ->
          EdmBackend.GraphQL.Schema.Client.find(id)
        _ ->
          EdmBackend.GraphQL.Schema.Client.find(id)
      end
    end)
  end

  def query do
    %ObjectType{
      name: "Root",
      description: "The query root of this schema. See available queries.",
      fields: %{
        node: node_field,
        clients: EdmBackend.GraphQL.Schema.Client.all_clients
      }
    }
  end

  def schema do
    %Schema{
      query: query
    }
  end
end
