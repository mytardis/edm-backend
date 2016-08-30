defmodule EdmBackend.GraphQL.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema
  alias EdmBackend.GraphQL.Resolver

  import_types EdmBackend.GraphQL.Types

  query do

    connection field :clients, node_type: :client do
      resolve fn
        pagination_args, _ ->
          Resolver.Client.list(pagination_args)
      end
    end

    connection field :instrument_groups, node_type: :instrument_group do
      resolve fn
        pagination_args, _ ->
          Resolver.InstrumentGroup.list(pagination_args)
      end
    end

    connection field :groups, node_type: :group do
      resolve fn
        pagination_args, _ ->
          Resolver.Group.list(pagination_args)
      end
    end

    connection field :users, node_type: :user do
      resolve fn
        pagination_args, _ ->
          Resolver.User.list(pagination_args)
      end
    end

    node field do
      resolve fn
        %{type: :client, id: id}, _ ->
          Resolver.Client.find(%{id: id})
        %{type: :instrument_group, id: id}, _ ->
          Resolver.InstrumentGroup.find(%{id: id})
        %{type: :facility, id: id}, _ ->
          Resolver.Facility.find(%{id: id})
        %{type: :group, id: id}, _ ->
          Resolver.Group.find(%{id: id})
        %{type: :user, id: id}, _ ->
          Resolver.User.find(%{id: id})
        %{type: :user_credentia, id: id}, _ ->
          Resolver.UserCredential.find(%{id: id})
      end
    end

  end

end
