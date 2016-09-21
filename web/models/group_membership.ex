defmodule EdmBackend.GroupMembership do
  @moduledoc """
  This is the many-to-many relationship model linking users to groups
  """
  use EdmBackend.Web, :model
  alias EdmBackend.User
  alias EdmBackend.Group

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "group_memberships" do
    belongs_to :user, User
    belongs_to :group, Group
    timestamps
  end

  def changeset(model, params \\ %{}) do
    model |> cast(params, [])
          |> cast_assoc(:user, required: true)
          |> cast_assoc(:group, required: true)
          |> unique_constraint(:membership, name: :group_memberships_user_id_group_id_index)
  end

end
