defmodule EdmBackend.UserCredential do
  @moduledoc """
  Represents a credential issued by a third-party auth provider
  """
  use EdmBackend.Web, :model
  alias EdmBackend.User

  schema "user_credentials" do
    field :auth_provider, :string
    field :remote_id, :string
    field :extra_data, :string
    belongs_to :user, User
    timestamps
  end

  @allowed ~w(auth_provider remote_id extra_data)a
  @required ~w(auth_provider remote_id)a

  def changeset(model, params \\ %{}) do
    model |> cast(params, @allowed)
          |> cast_assoc(:user, required: true)
          |> validate_required(@required)
          |> unique_constraint(:credential, name: :user_credentials_auth_provider_remote_id_index)
  end

end
