defmodule EdmBackend.GraphQL.Schema.Client do
  alias GraphQL.Relay.Node
  alias GraphQL.Relay.Connection
  alias GraphQL.Type.ObjectType
  alias GraphQL.Type.String
  alias EdmBackend.GraphQL.Schema.Root
  alias EdmBackend.Repo

  import Ecto.Query

  import Logger

  def type do
    %ObjectType{
      name: "Client",
      description: "An EDM client",
      fields: %{
        id: Node.global_id_field("client"),
        uuid: %{type: %String{}},
        ip_address: %{type: %String{}},
        nickname: %{type: %String{}}
      },
      interfaces: [Root.node_interface]
    }
  end

  def client_connection do
    %{
      name: "Client",
      node_type: type,
      edge_fields: %{},
      connection_fields: %{},
      resolve_node: nil,
      resolve_cursor: nil
    } |> Connection.new
  end

  def all_clients do
    %{
      type: EdmBackend.GraphQL.Schema.Client.client_connection[:connection_type],
      resolve: fn(_,args,_) ->
        clients = from client in EdmBackend.Client
        Connection.Ecto.resolve(Repo, clients, args)
      end,
      args: Map.merge(
        %{status: %{type: %String{}, defaultValue: "any"}},
        Connection.args
      ),
      interfaces: [Root.node_interface]
    }
  end

  def find(id) do
    EdmBackend.Client
      |> preload(:facility)
      |> Repo.get(id)
  end
end
