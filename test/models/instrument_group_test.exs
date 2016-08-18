defmodule EdmBackend.InstrumentGroupModelTest do
  use EdmBackend.ModelCase
  alias EdmBackend.Facility
  alias EdmBackend.InstrumentGroup

  test "valid instrument group values" do
    facility = %Facility{
      name: "test facility"
    } |> Facility.changeset

    {:ok, facility} = Repo.insert facility

    instrument_group = %InstrumentGroup{
      name: "A config group",
      configuration_blob: "{some: 'config'}",
      facility: facility
    } |> InstrumentGroup.changeset

    assert instrument_group.valid?
  end

  test "invalid instrument group values" do
    facility = %Facility{
      name: "test facility"
    } |> Facility.changeset

    {:ok, facility} = Repo.insert facility

    instrument_group1 = %InstrumentGroup{
      configuration_blob: "{some: 'config'}",
      facility: facility
    } |> InstrumentGroup.changeset
    instrument_group2 = %InstrumentGroup{
      name: "A config group",
      facility: facility
    } |> InstrumentGroup.changeset
    instrument_group3 = %InstrumentGroup{
      name: "A config group",
      configuration_blob: "{some: 'config'}"
    } |> InstrumentGroup.changeset

    refute instrument_group1.valid?
    refute instrument_group2.valid?
    refute instrument_group3.valid?
  end

  test "facility uniqueness" do

  end

end
