defmodule EdmBackend.ConfigurationGroup do
  use EdmBackend.Web, :model

  schema "configuration_groups" do
    field :name, :string
    field :description, :string
    field :configuration_blob, :string
    has_many :clients, EdmBackend.Client
    belongs_to :facility, EdmBackend.Facility
    timestamps
  end
end
