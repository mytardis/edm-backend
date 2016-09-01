defmodule EdmBackend.Facility do
  @moduledoc """
  Represents a facility, which is effectively a container for instrument groups
  """

  use EdmBackend.Web, :model
  alias EdmBackend.Client
  alias EdmBackend.InstrumentGroup

  schema "facilities" do
    field :name, :string
    has_many :instrument_groups, InstrumentGroup
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
