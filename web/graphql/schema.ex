defmodule EdmBackend.GraphQL.Schema do
  require Logger
  use Absinthe.Schema
  use Absinthe.Relay.Schema
  alias EdmBackend.GraphQL.Resolver
  alias EdmBackend.Client

  import_types EdmBackend.GraphQL.Types

  query do

    @desc "Lists all clients"
    connection field :clients, node_type: :client do
      resolve fn
        pagination_args, _ ->
          Resolver.Client.list(pagination_args)
      end
    end

    @desc "Shows information about the currently logged in client"
    field :current_client, :client do
      resolve fn
        _, %{context: %{current_resource: %Client{} = current_client}} ->
          Resolver.Client.find(%{id: current_client.id})
        _, _ ->
          Resolver.Client.find(%{id: "bdeffb9c-652e-485b-bdf1-08de73ee9be0"})
        # debug with hard coded client
          # {:error, "Not logged in"}
      end
    end

    node field do
      resolve fn
        %{type: :client, id: id}, _ ->
          Resolver.Client.find(%{id: id})
        %{type: :group, id: id}, _ ->
          Resolver.Group.find(%{id: id})
        %{type: :credential, id: id}, _ ->
          Resolver.Credential.find(%{id: id})
        %{type: :file, id: id}, _ ->
          Resolver.File.find(%{id: id})
      end
    end

  end

  mutation do
    payload field :create_file do
      input do
        field :file, :file_input_object
      end
      output do
        field :file, :file
      end
      resolve &Resolver.File.create/2
    end

    payload field :update_file do

    end

    payload field :delete_file do

    end

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
