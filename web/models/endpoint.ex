defmodule EdmBackend.Endpoint do
  use EdmBackend.Web, :model
  alias EdmBackend.Destination

  schema "endpoints" do
    field :name, :string
    field :transfer_method, :string
    field :settings, :map

    has_many :destinations, Destination

    timestamps
  end
end
