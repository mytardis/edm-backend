defmodule EdmBackend.GroupMembership do
  use EdmBackend.Web, :model

  schema "group_memberships" do
    belongs_to :user, EdmBackend.User
    belongs_to :group, EdmBackend.Group
    timestamps
  end

  def changeset(model, params \\ %{}) do
    model |> cast(params, [])
          |> cast_assoc(:user, required: true)
          |> cast_assoc(:group, required: true)
          |> unique_constraint(:membership, name: :group_memberships_user_id_group_id_index)
  end

end
