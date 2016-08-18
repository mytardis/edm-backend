defmodule EdmBackend.User do
  use EdmBackend.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    has_many :credentials, EdmBackend.UserCredential
    has_many :group_memberships, EdmBackend.GroupMembership
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

end
