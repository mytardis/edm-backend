defmodule EdmBackend.GraphQL.Types do
  require Logger
  import EdmBackend.GraphQL.Helper
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

  scalar :datetime do
    parse fn(input) ->
      %{value: value} = input
      Calendar.DateTime.Parse.rfc3339_utc(value)
    end
    serialize &Calendar.DateTime.Format.rfc3339/1
  end

  node interface do
    resolve_type fn
      %EdmBackend.Client{}, _ -> :client
      %EdmBackend.Group{}, _ -> :group
      %EdmBackend.Destination{}, _ -> :destination
      %EdmBackend.File{}, _ -> :file
      %EdmBackend.FileTransfer{}, _ -> :file_transfer
      %EdmBackend.Host{}, _ -> :host
      %EdmBackend.Source{}, _ -> :source
    end
  end

  connection node_type: :group
  node object :group do
    field :name, non_null(:string)
    connection field :members, node_type: :client do
      resolve fn
        pagination_args, get_viewer_and_source(viewer, group) ->
          Resolver.Group.list_members(pagination_args, group, viewer)
      end
    end
  end

  node object :host do
    field :name, :string
    field :transfer_method, :string
    field :settings, :map
  end

  node object :destination do
    field :base, :string  # path in destination
    field :name, :string
    field :host_id, type: :string do
      resolve fn _, get_viewer_and_source(viewer, destination) ->
        {:ok, %{id: id}} = Resolver.Host.find(%{destination: destination}, viewer)
        {:ok, id}
      end
    end
  end

  connection node_type: :file_transfer
  node object :file_transfer do
    field :transfer_status, :string
    field :bytes_transferred, :integer
    field :destination, type: :destination
  end

  connection node_type: :file
  node object :file do
    field :filepath, :string
    field :size, :integer
    field :mode, :integer
    field :atime, :datetime
    field :mtime, :datetime
    field :ctime, :datetime
    field :birthtime, :datetime
    connection field :file_transfers, node_type: :file_transfer do
      resolve fn pagination_args, get_viewer_and_source(viewer, file) ->
        Resolver.FileTransfer.list(pagination_args, file, viewer)
      end
    end
  end

  connection node_type: :source
  node object :source do
    field :name, :string
    field :fstype, :string
    field :settings, :map

    connection field :files, node_type: :file do
      resolve fn pagination_args, get_viewer_and_source(viewer, source) ->
        Resolver.File.list(pagination_args, source, viewer)
      end
    end
    field :file, type: :file do
      arg :filepath, :string
      resolve fn %{filepath: filepath}, get_viewer_and_source(viewer, source) ->
        Resolver.File.find(source, filepath, viewer)
      end
    end
    field :destinations, list_of(:destination) do
      resolve fn _, get_viewer_and_source(viewer, source) ->
        Resolver.Destination.list_destinations(source, viewer)
      end
    end
  end

  connection node_type: :client
  node object :client do
    field :name, non_null(:string)
    field :attributes, :map
    connection field :groups, node_type: :group do
      resolve fn
        pagination_args, get_viewer_and_source(viewer, client) ->
          Resolver.Client.list_groups(pagination_args, client, viewer)
      end
    end
    field :sources, list_of(:source) do
      resolve fn
        _args, get_viewer_and_source(viewer, client) ->
          Resolver.Source.list(client, viewer)
      end
    end
    field :hosts, list_of(:host) do
      resolve fn _args, get_viewer_and_source(viewer, client) ->
        Resolver.Host.list_hosts(client, viewer)
      end
    end
    field :source, type: :source do
      arg :name, :string
      resolve fn %{name: name}, get_viewer_and_source(viewer, client) ->
        Resolver.Source.find(client, name, viewer)
      end
    end
  end

  input_object :source_input_object do
    field :name, :string
    field :fstype, :string
    field :settings, :map
  end

  input_object :file_input_object do
    field :filepath, :string
    field :size, :integer
    field :mode, :integer
    field :atime, :datetime
    field :mtime, :datetime
    field :ctime, :datetime
    field :birthtime, :datetime
  end
end
