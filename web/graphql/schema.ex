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
          # Resolver.Client.find(%{id: "bdeffb9c-652e-485b-bdf1-08de73ee9be0"})
        # debug with hard coded client
          {:error, "Not logged in"}
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
    payload field :get_or_create_file do
      input do
        field :source, :source_input_object
        field :file, :file_input_object
      end
      output do
        field :file, type: :file
        field :file_id, :string
      end
      resolve fn %{source: %{name: source_name}, file: file_info},
        %{context: %{current_resource: client}} ->
          # get source by client and name, get file by source and file info
          case Resolver.Source.find(client, source_name) do
            {:ok, source} ->
              {:ok, file} = Resolver.File.get_or_create(source, file_info)
              {:ok, %{file_id: file.id, file: file}}
            {:error, error} ->
              {:error, error}
          end
        _, _ ->
          {:error, "Not logged in"}
      end
    end

    payload field :get_or_create_source do
      input do
        field :source, :source_input_object
      end
      output do
        field :source, type: :source
      end
      resolve fn %{source: source_info},
        %{context: %{current_resource: client}} ->
          {:ok, source} = Resolver.Source.get_or_create(client, source_info)
          {:ok, %{source: source}}
        _, _ ->
          {:error, "Not logged in"}
      end
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
