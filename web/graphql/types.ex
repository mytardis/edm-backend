defmodule EdmBackend.GraphQL.Types do
  require Logger
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation
  alias EdmBackend.GraphQL.Resolver

  @desc """
  This scalar contains arbitrary map data that does not have a predefined schema
  available in GraphQL.
  """
  scalar :map, description: "Arbitrary map data" do
    parse fn (value) when is_map(value) ->
      {:ok, value}
    end
    serialize fn (value) when is_map(value) ->
      value
    end
  end

  node interface do
    resolve_type fn
      %EdmBackend.Client{}, _ -> :client
      %EdmBackend.Group{}, _ -> :group
    end
  end

  connection node_type: :group
  node object :group do
    field :name, non_null(:string)
    field :parent, :group do
      resolve fn
        _, %{source: group} ->
          group |> Resolver.Group.get_parent
      end
    end
    connection field :children, node_type: :group do
      resolve fn
        pagination_args, %{source: group} ->
          Resolver.Group.list_children(pagination_args, group)
      end
    end
    connection field :members, node_type: :client do
      resolve fn
        pagination_args, %{source: group} ->
          Resolver.Group.list_members(pagination_args, group)
      end
    end
  end

  connection node_type: :credential
  node object :credential do
    field :auth_provider, non_null(:string)
    field :remote_id, non_null(:string)
    field :extra_data, :map
  end

  connection node_type: :client
  node object :client do
    field :name, non_null(:string)
    field :attributes, :map
    connection field :groups, node_type: :group do
      resolve fn
        pagination_args, %{source: client} ->
          Resolver.Client.list_groups(pagination_args, client)
      end
    end
    connection field :groups_flat, node_type: :group do
      resolve fn
        pagination_args, %{source: client} ->
          Resolver.Client.list_groups_flat(pagination_args, client)
      end
    end
    connection field :credentials, node_type: :credential do
      resolve fn
        pagination_args, %{source: client} ->
          Resolver.Credential.list(pagination_args, client)
      end
    end
  end

end
