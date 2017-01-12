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

  schema "groups" do
    field :name, :string
    field :description, :string
    has_many :group_memberships, GroupMembership, on_delete: :delete_all
    has_many :clients, through: [:group_memberships, :client]
    has_many :destinations, Destination
    timestamps()
  end

  @allowed ~w(name description)a
  @required ~w(name description)a

  def changeset(model, params \\ %{}) do
    model |> cast(params, @allowed)
          |> validate_required(@required)
          |> unique_constraint(:name)
  end

  @doc """
  Returns a list of clients who are members of this group
  """
  def members(group) do
    %{clients: members} = group |> Repo.preload(:clients)
    members
  end

end
