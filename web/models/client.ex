defmodule EdmBackend.Client do
  @moduledoc """
  Represents a client
  """

  require Logger
  use EdmBackend.Web, :model
  alias EdmBackend.Repo
  alias EdmBackend.Client
  alias EdmBackend.Group
  alias EdmBackend.Credential
  alias EdmBackend.GroupMembership
  import Ecto.Query

  schema "clients" do
    field :name, :string
    field :attributes, :map
    has_many :credentials, Credential
    has_many :group_memberships, GroupMembership
    has_many :groups, through: [:group_memberships, :group]
    timestamps
  end

  @allowed ~w(name attributes)a
  @required ~w(name)a

  def changeset(model, params \\ %{}) do
    model |> cast(params, @allowed)
          |> validate_required(@required)
  end

  def get_or_create(provider, client_info, extra_data \\ %{}) when is_atom(provider) do
    get_or_create(Atom.to_string(provider), client_info, extra_data)
  end

  def get_or_create(provider, %{id: uid, name: name}, extra_data) do
    query = from cred in Credential,
              where: cred.remote_id == ^uid,
              where: cred.auth_provider == ^provider
    case Repo.one(query) do
      nil ->
        result = Repo.transaction fn ->
          client = %Client{} |> Client.changeset(%{name: name}) |> Repo.insert!
          %Credential{
            client: client
          } |> Credential.changeset(%{
            auth_provider: provider,
            remote_id: uid,
            extra_data: extra_data})
          |> Repo.insert!
          client
        end
        result
      client_credential ->
        client_credential = client_credential |> Repo.preload(:client)
        client_credential |> Credential.changeset(%{extra_data: extra_data})
                          |> Repo.update!
        {:ok, client_credential.client}
    end
  end

  @doc """
  Adds a client to a group
  """
  def add_to_group(client, group) do
    %GroupMembership{
      client: client,
      group: group
    } |> GroupMembership.changeset
      |> Repo.insert
  end

  def remove_from_group(%Client{id: client_id}, %Group{id: group_id}) do
    query = from m in GroupMembership,
              where: m.client_id == ^client_id,
              where: m.group_id == ^group_id
    query |> Repo.delete_all
  end

  @doc """
  Generates a flattened list of groups that a client belongs to
  """
  def all_groups_flat(client) do
    %{groups: groups} = client |> Repo.preload(:groups)

    groups = groups |> Enum.map(fn(g) ->
      g |> Group.load_parents
    end)

    all_groups_flat groups, %MapSet{}
  end

  defp all_groups_flat([%Group{parent: parent} = head|tail], accumulator) when is_nil(parent) do
    all_groups_flat(tail, accumulator |> MapSet.put(head))
  end

  defp all_groups_flat([head|tail], accumulator) do
    all_groups_flat(tail ++ [head.parent], accumulator |> MapSet.put(head))
  end

  defp all_groups_flat([], accumulator) do
    accumulator |> MapSet.to_list
  end

  @doc """
  Generates a nested list of groups that a client belongs to, maintaining any
  hierarchical group relationships
  """
  def all_groups(client) do
    client |> Repo.preload(:groups)
           |> Map.get(:groups)
           |> Enum.map(fn(g) ->
             g |> Group.load_parents
         end)
  end

  @doc """
  Determines whether the given client is a member of the specified group
  """
  def member_of?(client, %Group{id: gid}) do
    client |> member_of?(gid)
  end

  def member_of?([%Group{parent: parent}|tail], target_gid) when is_nil(parent) do
    member_of? tail, target_gid
  end

  def member_of?([], _target_gid) do
    false
  end

  def member_of?([%Group{id: gid}|_tail], target_gid) when gid == target_gid do
    true
  end

  def member_of?([head|tail], target_gid) do
    member_of? tail ++ [head.parent], target_gid
  end

  def member_of?(client, gid) do
    client |> all_groups |> member_of?(gid)
  end

end
