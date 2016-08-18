defmodule EdmBackend.InstrumentGroup do
  use EdmBackend.Web, :model

  schema "instrument_groups" do
    field :name, :string
    field :description, :string
    field :configuration_blob, :string
    has_many :clients, EdmBackend.Client
    belongs_to :facility, EdmBackend.Facility
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
