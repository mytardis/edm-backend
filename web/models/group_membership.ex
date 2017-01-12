defmodule EdmBackend.GroupMembership do
  @moduledoc """
  This is the many-to-many relationship model linking clients to groups
  """
  use EdmBackend.Web, :model
  alias EdmBackend.Client
  alias EdmBackend.Group

  schema "group_memberships" do
    belongs_to :client, Client
    belongs_to :group, Group
    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model |> cast(params, [])
          |> cast_assoc(:client, required: true)
          |> cast_assoc(:group, required: true)
          |> unique_constraint(:membership, name: :group_memberships_client_id_group_id_index)
  end

end
