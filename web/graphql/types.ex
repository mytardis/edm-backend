defmodule EdmBackend.GraphQL.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation
  alias EdmBackend.GraphQL.Resolver
  import Logger

  node interface do
    resolve_type fn
      %EdmBackend.Client{}, _ -> :client
      %EdmBackend.Facility{}, _ -> :facility
      %EdmBackend.InstrumentGroup{}, _ -> :instrument_group
      %EdmBackend.Group{}, _ -> :group
      %EdmBackend.User{}, _ -> :user
    end
  end

  node object :facility do
    field :name, non_null(:string)
    connection field :instrument_groups, node_type: :instrument_group do
      resolve fn
        pagination_args, %{source: facility} ->
          Resolver.InstrumentGroup.list(pagination_args, facility)
      end
    end
  end

  connection node_type: :client
  node object :client do
    field :uuid, non_null(:string)
    field :nickname, non_null(:string)
    field :ip_address, non_null(:string)
    field :facility, :facility do
      resolve fn
        _, %{source: client} ->
          client |> Resolver.Facility.find
      end
    end
  end

  connection node_type: :instrument_group
  node object :instrument_group do
    field :name, non_null(:string)
    field :description, :string
    field :configuration_blob, :string
    connection field :clients, node_type: :client do
      resolve fn
        pagination_args, %{source: instrument_group} ->
          Resolver.Client.list(pagination_args, instrument_group)
      end
    end
    field :facility, :facility do
      resolve fn _, %{source: instrument_group} ->
        instrument_group |> Resolver.Facility.find
      end
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
    connection field :members, node_type: :user do
      resolve fn
        pagination_args, %{source: group} ->
          Resolver.Group.list_members(pagination_args, group)
      end
    end
  end

  connection node_type: :user_credential
  node object :user_credential do
    field :auth_provider, non_null(:string)
    field :remote_id, non_null(:string)
    field :extra_data, :string
  end

  connection node_type: :user
  node object :user do
    field :name, non_null(:string)
    field :email, non_null(:string)
    connection field :groups, node_type: :group do
      resolve fn
        pagination_args, %{source: user} ->
          Resolver.User.list_groups(pagination_args, user)
      end
    end
    connection field :groups_flat, node_type: :group do
      resolve fn
        pagination_args, %{source: user} ->
          Resolver.User.list_groups_flat(pagination_args, user)
      end
    end
    connection field :user_credentials, node_type: :user_credential do
      resolve fn
        pagination_args, %{source: user} ->
          Resolver.UserCredential.list(pagination_args, user)
      end
    end
  end

end
