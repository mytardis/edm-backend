defmodule EdmBackend.Client do
  use EdmBackend.Web, :model

  schema "clients" do
    field :uuid, :string
    field :ip_address, :string
    field :nickname, :string
    belongs_to :instrument_group, EdmBackend.InstrumentGroup
    timestamps
  end

  @allowed ~w(uuid ip_address nickname)a
  @required ~w(uuid ip_address)a

  def changeset(model, params \\ %{}) do
    model
      |> cast(params, @allowed)
      |> validate_required(@required)
      |> validate_format(:uuid, ~r/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
      |> unique_constraint(:uuid)
  end

end
