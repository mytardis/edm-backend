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
        field :source_id, :id
        field :file, :file_input_object
      end
      output do
        field :file, type: :file
      end
      resolve fn %{source_id: source_id, file: file_info}, get_viewer(viewer) ->
          case Resolver.Source.from_global_id(source_id, viewer) do
            {:ok, source} ->
              case Resolver.File.create_or_update(source, file_info, viewer) do
                {:ok, file} -> {:ok, %{file: file}}
                {:error, error} -> {:error, error}
              end
            {:error, error} ->
              {:error, error}
          end
        _, _ ->
          {:error, @not_logged_in_error}
      end
    end

    payload field :update_file do
      input do
        field :file_id, non_null(:id)
        field :file, :file_input_object
      end
      output do
        field :file, type: :file
      end
      resolve fn
        %{file_id: file_id, file: file_info}, get_viewer(viewer) ->
          case Resolver.File.from_global_id(file_id) do
            {:ok, file} ->
              case Resolver.File.update(file, file_info, viewer) do
                {:ok, file} -> {:ok, %{file: file}}
                {:error, error} -> {:error, error}
              end
            {:error, error} -> {:error, error}
          end
        _, _ ->
          {:error, @not_logged_in_error}
      end
    end

    payload field :update_file_transfer do
      input do
        field :file_transfer_id, non_null(:id)
        field :file_transfer, :file_transfer_input_object
      end
      output do
        field :file_transfer, type: :file_transfer
      end
      resolve fn
        %{file_transfer_id: file_transfer_id, file_transfer: new_file_transfer}, get_viewer(viewer) ->
          case Resolver.FileTransfer.from_global_id(file_transfer_id) do
            {:ok, file_transfer} ->
              case Resolver.FileTransfer.update(file_transfer, new_file_transfer, viewer) do
                {:ok, updated_file_transfer} ->
                  {:ok, %{file_transfer: updated_file_transfer}}
                {:error, error} -> {:error, error}
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
        field :file_id, non_null(:id)
      end
      output do
        field :file, type: :file
      end
      resolve fn
        %{file_id: file_id}, get_viewer(viewer) ->
          case Resolver.File.from_global_id(file_id) do
            {:ok, file} ->
              case Resolver.File.delete(file, viewer) do
                {:ok, file} ->
                  {:ok, %{file: file}}
                {:error, error} ->
                  {:error, error}
              end
            {:error, error} -> {:error, error}
          end
        _, _ ->
          {:error, @not_logged_in_error}
      end
    end

  end

end
