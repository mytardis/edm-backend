defmodule EdmBackend.GraphQL.Schema do
  require Logger
  import EdmBackend.GraphQL.Helper
  use Absinthe.Schema
  use Absinthe.Relay.Schema
  alias EdmBackend.GraphQL.Resolver

  import_types EdmBackend.GraphQL.Types

  @not_logged_in_error "Not logged in"

  query do

    @desc "Lists all clients"
    connection field :clients, node_type: :client do
      resolve fn
        pagination_args, get_viewer(viewer) ->
          Resolver.Client.list(pagination_args, viewer)
      end
    end

    @desc "Shows information about the currently logged in client"
    field :current_client, :client do
      resolve fn
        _, get_viewer(viewer) ->
          Resolver.Client.find(%{id: viewer.id}, viewer)
        _, _ ->
          {:error, @not_logged_in_error}
      end
    end

    node field do
      resolve fn
        %{type: :client, id: id}, get_viewer(viewer) ->
          Resolver.Client.find(%{id: id}, viewer)
        %{type: :group, id: id}, get_viewer(viewer) ->
          Resolver.Group.find(%{id: id}, viewer)
        %{type: :destination, id: id}, get_viewer(viewer) ->
          Resolver.Destination.find(%{id: id}, viewer)
        %{type: :file, id: id}, get_viewer(viewer) ->
          Resolver.File.find(%{id: id}, viewer)
        %{type: :file_transfer, id: id}, get_viewer(viewer) ->
          Resolver.FileTransfer.find(%{id: id}, viewer)
        %{type: :host, id: id}, get_viewer(viewer) ->
          Resolver.Host.find(%{id: id}, viewer)
        %{type: :source, id: id}, get_viewer(viewer) ->
          Resolver.Source.find(%{id: id}, viewer)
      end
    end
  end

  mutation do
    payload field :create_or_update_file do
      input do
        field :source, :source_input_object
        field :file, :file_input_object
      end
      output do
        field :file_id, :string
        field :file, type: :file
      end
      resolve fn %{source: %{name: source_name}, file: file_info}, get_viewer(viewer) ->
          # get source by client and name, get file by source and file info
          case Resolver.Source.find(viewer, source_name, viewer) do
            {:ok, source} ->
              {:ok, file} = Resolver.File.create_or_update(source, file_info, viewer)
              {:ok, %{file_id: file.id, file: file}}
            {:error, error} ->
              {:error, error}
          end
        _, _ ->
          {:error, @not_logged_in_error}
      end
    end

    payload field :update_file do
      input do
        field :source, :source_input_object
        field :file, :file_input_object
      end
      output do
        field :file, type: :file
        field :file_id, type: :string
      end
      resolve fn
        %{source: %{name: source_name}, file: file_info}, get_viewer(viewer) ->
          case Resolver.Source.find(viewer, source_name, viewer) do
            {:ok, source} ->
              case Resolver.File.update(source, file_info, viewer) do
                {:ok, file} ->
                  {:ok, %{file_id: file.id, file: file}}
                {:error, error} ->
                  {:error, error}
              end
            {:error, error} ->
              {:error, error}
          end
        _, _ ->
          {:error, @not_logged_in_error}
      end
    end

    payload field :get_or_create_source do
      input do
        field :source, :source_input_object
      end
      output do
        field :source, type: :source
      end
      resolve fn
        %{source: source_info}, get_viewer(viewer) ->
          case Resolver.Source.get_or_create(viewer, source_info, viewer) do
            {:ok, source} ->
              {:ok, %{source: source}}
            {:error, error} ->
              {:error, error}
          end
        _, _ ->
          {:error, @not_logged_in_error}
      end
    end

    payload field :delete_file do
      input do
        field :file_id, :string
      end
      output do
        field :file, type: :file
      end
      resolve fn
        %{file: file}, get_viewer(viewer) ->
          case Resolver.File.delete(viewer, file, viewer) do
            {:ok, file} ->
              {:ok, %{file: file}}
            {:error, error} ->
              {:error, error}
          end
        _, _ ->
          {:error, @not_logged_in_error}
      end
    end

    #payload field :create_client do
    #  input dof
    #    field :uuid, non_null(:string)
    #  end
    #  output do
    #    field :token, :string
    #  end
    #  resolve fn
    #    %{input_data: input_data}, _ ->
    #      # Some mutation side-effect here
    #      {:ok, %{result: input_data * 2}}
    #  end
    #end
  end

end
