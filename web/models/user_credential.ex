defmodule EdmBackend.UserCredential do
  use EdmBackend.Web, :model

  schema "user_credentials" do
    field :auth_provider, :string
    field :remote_id, :string
    belongs_to :person, EdmBackend.Person
    timestamps
  end
end
