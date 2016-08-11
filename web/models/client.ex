defmodule EdmBackend.Client do
  use EdmBackend.Web, :model

  schema "clients" do
    field :uuid, :string
    field :ip_address, :string
    field :nickname, :string
    belongs_to :configuration_group, EdmBackend.ConfigurationGroup
    timestamps
  end

  @allowed ~w(uuid ip_address nickname)

  def changeset(model, params \\ :empty) do
    model
      |> cast(params, @allowed)
      |> validate_required([:uuid, :ip_address])
      |> validate_format(:uuid, ~r/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
      |> unique_constraint(:uuid)
  end

end
