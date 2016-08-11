defmodule EdmBackend.User do
  use EdmBackend.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    has_many :credentials, EdmBackend.UserCredential
    has_many :groups, EdmBackend.Group
    timestamps
  end
end
