defmodule EdmBackend.Facility do
  use EdmBackend.Web, :model

  schema "facilities" do
    field :name, :string
    has_many :clients, EdmBackend.Client
    timestamps
  end

  @required_fields ~w(name)

  def changeset(model, params \\ :empty) do
    model |> cast(params, @required_fields, [])
  end

end