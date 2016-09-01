defmodule EdmBackend.User do
  @moduledoc """
  Represents a user
  """

  use EdmBackend.Web, :model
  alias EdmBackend.Repo
  alias EdmBackend.User
  alias EdmBackend.Group
  alias EdmBackend.UserCredential
  alias EdmBackend.GroupMembership
  import Ecto.Query

  schema "users" do
    field :name, :string
    field :email, :string
    has_many :credentials, UserCredential
    has_many :group_memberships, GroupMembership
    has_many :groups, through: [:group_memberships, :group]
    timestamps
  end

  @allowed ~w(name email)a
  @required ~w(name email)a

  def changeset(model, params \\ %{}) do
    model |> cast(params, @allowed)
          |> validate_required(@required)
          |> unique_constraint(:email)
  end

  @doc """
  Adds a user to a group
  """
  def add_to_group(user, group) do
    %GroupMembership{
      user: user,
      group: group
    } |> GroupMembership.changeset
      |> Repo.insert
  end

  def remove_from_group(%User{id: user_id}, %Group{id: group_id}) do
    query = from m in GroupMembership,
              where: m.user_id == ^user_id,
              where: m.group_id == ^group_id
    query |> Repo.delete_all
  end

  @doc """
  Generates a flattened list of groups that a user belongs to
  """
  def all_groups_flat(user) do
    %{groups: groups} = user |> Repo.preload(:groups)

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
  Generates a nested list of groups that a user belongs to, maintaining any
  hierarchical group relationships
  """
  def all_groups(user) do
    user |> Repo.preload(:groups)
         |> Map.get(:groups)
         |> Enum.map(fn(g) ->
           g |> Group.load_parents
         end)
  end

  @doc """
  Determines whether the given user is a member of the specified group
  """
  def member_of?(user, %Group{id: gid}) do
    user |> member_of?(gid)
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

  def member_of?(user, gid) when is_integer(gid) do
    user |> all_groups |> member_of?(gid)
  end

end
