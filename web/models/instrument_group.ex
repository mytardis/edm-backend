defmodule EdmBackend.InstrumentGroup do
  @moduledoc """
  Represents one or more clients that share a configuration and belongs to a
  facility
  """
  use EdmBackend.Web, :model
  alias EdmBackend.Client
  alias EdmBackend.Facility

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "instrument_groups" do
    field :name, :string
    field :description, :string
    field :configuration_blob, :string
    has_many :clients, Client
    belongs_to :facility, Facility
    timestamps
  end

  @allowed ~w(name description configuration_blob)a
  @required ~w(name configuration_blob)a

  def changeset(model, params \\ %{}) do
    model |> cast(params, @allowed)
          |> validate_required(@required)
          |> cast_assoc(:facility, required: true)
          |> unique_constraint(:name, name: :instrument_groups_name_facility_id_index)
  end
end
