defmodule EdmBackend.Group do
  @moduledoc """
  Represents client groups, and group hierarchies
  """

  require Logger
  use EdmBackend.Web, :model
  alias EdmBackend.Repo
  alias EdmBackend.Destination
  alias EdmBackend.Group
  alias EdmBackend.GroupMembership
  alias EdmBackend.Host
  alias EdmBackend.Client
  alias EdmBackend.Source
  alias EdmBackend.File
  alias EdmBackend.FileTransfer

  schema "groups" do
    field :name, :string
    field :description, :string
    has_many :group_memberships, GroupMembership, on_delete: :delete_all
    has_many :clients, through: [:group_memberships, :client]
    timestamps()
  end

  @allowed ~w(name description)a
  @required ~w(name description)a

  def changeset(model, params \\ %{}) do
    model |> cast(params, @allowed)
          |> validate_required(@required)
          |> unique_constraint(:name)
  end

  def get_by_name(name) do
    q = from group in Group,
      where: group.name == ^name
    case Repo.one(q) do
      nil ->
        {:error, "Group not found"}
      group ->
        {:ok, group}
    end
  end

  def get_groups_for(%Group{} = group) do
    [group]
  end

  def get_groups_for(%Host{} = host) do
    [host |> Repo.preload(:group) |> Map.get(:group)]
  end

  def get_groups_for(%Client{} = client) do
    Client.all_groups(client)
  end

  def get_groups_for(%Source{} = source) do
    get_groups_for(source |> Repo.preload(:owner) |> Map.get(:owner))
  end

  def get_groups_for(%Destination{} = destination) do
    get_groups_for(destination |> Repo.preload(:host) |> Map.get(:host))
  end

  def get_groups_for(%File{} = file) do
    get_groups_for(file |> Repo.preload(:source) |> Map.get(:source))
  end

  def get_groups_for(%FileTransfer{} = file_transfer) do
    get_groups_for(file_transfer |> Repo.preload(:file) |> Map.get(:file))
  end

end
