defmodule EdmBackend.GraphQL.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema
  alias EdmBackend.GraphQL.Resolver
  alias EdmBackend.User
  alias EdmBackend.Client
  require Logger

  import_types EdmBackend.GraphQL.Types

  query do

    @desc "Lists all clients"
    connection field :clients, node_type: :client do
      resolve fn
        pagination_args, _ ->
          Resolver.Client.list(pagination_args)
      end
    end

    @desc "Lists all instrument groups"
    connection field :instrument_groups, node_type: :instrument_group do
      resolve fn
        pagination_args, _ ->
          Resolver.InstrumentGroup.list(pagination_args)
      end
    end

    @desc "Lists all user groups"
    connection field :groups, node_type: :group do
      resolve fn
        pagination_args, _ ->
          Resolver.Group.list(pagination_args)
      end
    end

    @desc "Lists all users"
    connection field :users, node_type: :user do
      resolve fn
        pagination_args, _ ->
          Resolver.User.list(pagination_args)
      end
    end

    @desc "Shows information about the currently logged in user"
    field :current_user, :user do
      resolve fn
        _, %{context: %{current_resource: %User{} = current_user}} ->
          Resolver.User.find(%{id: current_user.id})
        _, _ ->
          {:error, "Not logged in"}
      end
    end

    @desc "Shows information about the currently logged in client"
    field :current_client, :client do
      resolve fn
        _, %{context: %{current_resource: %Client{} = current_client}} ->
          Resolver.Client.find(%{id: current_client.id})
        _, _ ->
          {:error, "Not logged in"}
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
        %{type: :user_credential, id: id}, _ ->
          Resolver.UserCredential.find(%{id: id})
      end
    end

  end

  mutation do
    payload field :create_client do
      input do
        field :uuid, non_null(:string)
      end
      output do
        field :token, :string
      end
      resolve fn
        %{input_data: input_data}, _ ->
          # Some mutation side-effect here
          {:ok, %{result: input_data * 2}}
      end
    end
  end

end
