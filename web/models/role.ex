defmodule EdmBackend.Role do
  use EdmBackend.Web, :model
  alias EdmBackend.Repo
  alias EdmBackend.Client
  alias EdmBackend.Group
  alias EdmBackend.GroupMembership
  alias EdmBackend.Role
  alias EdmBackend.Ownership

  schema "roles" do
    field :name, :string
    field :description, :string
    field :type, :string
    belongs_to :source_group, Group
    belongs_to :target_group, Group
    timestamps()
  end

  @allowed ~w(name description type)a
  @required ~w(name type)a

  def changeset(model, params \\ %{}) do
    model |> Ecto.Changeset.cast(params, @allowed)
          |> cast_assoc(:source_group, required: true)
          |> cast_assoc(:target_group, required: true)
          |> validate_required(@required)
          |> unique_constraint(:type, name: :roles_type_source_group_id_target_group_id_index)
  end

  def get_role_query(type, client, target) do
    owner_group_ids = for g <- Ownership.of(target), do: g.id
    from role in Role,
      join: group_memberships in GroupMembership,
      where: group_memberships.client_id == ^client.id,
      where: group_memberships.group_id == role.source_group_id,
      where: role.target_group_id in ^owner_group_ids,
      where: role.type == ^type
  end

  def has_role?(type, client, target) when is_atom(type) do
    has_role?(Atom.to_string(type), client, target)
  end

  def has_role?(type, client, target) when is_binary(type) do
    get_role_query(type, client, target) |> Repo.aggregate(:count, :id) > 0
  end

  def has_role?(role = %Role{}, client, target) do
    role = role |> Repo.preload(:source_group) |> Repo.preload(:target_group)
    Client.member_of?(client, role.source_group) and
      Enum.any?(Ownership.of(target), fn(group) ->
        group.id == role.target_group.id
      end)
  end

end
