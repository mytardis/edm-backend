defmodule EdmBackend.Facility do
  use EdmBackend.Web, :model

  schema "facilities" do
    field :name, :string
    has_many :clients, EdmBackend.Client
    has_many :instrument_groups, EdmBackend.InstrumentGroup
    timestamps
  end

  @allowed ~w(name)a
  @required ~w(name)a

  def changeset(model, params \\ %{}) do
    model |> cast(params, @allowed)
          |> validate_required(@required)
          |> unique_constraint(:name)
  end

end
