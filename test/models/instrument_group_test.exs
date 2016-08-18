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

  test "instrument group uniqueness" do
    facility1 = %Facility{
      name: "test facility1"
    } |> Facility.changeset
    facility2 = %Facility{
      name: "test facility2"
    } |> Facility.changeset

    {:ok, facility1} = Repo.insert facility1
    {:ok, facility2} = Repo.insert facility2

    instrument_group1a = %InstrumentGroup{
      name: "A config group",
      configuration_blob: "{some: 'config'}",
      facility: facility1
    } |> InstrumentGroup.changeset
    instrument_group2a = %InstrumentGroup{
      name: "A config group",
      configuration_blob: "{some: 'config'}",
      facility: facility1
    } |> InstrumentGroup.changeset
    instrument_group3a = %InstrumentGroup{
      name: "Another config group",
      configuration_blob: "{some: 'config'}",
      facility: facility1
    } |> InstrumentGroup.changeset

    assert {:ok, _changeset} = Repo.insert instrument_group1a
    assert {:error, _changeset} = Repo.insert instrument_group2a
    assert {:ok, _changeset} = Repo.insert instrument_group3a

    instrument_group1b = %InstrumentGroup{
      name: "A config group",
      configuration_blob: "{some: 'config'}",
      facility: facility2
    } |> InstrumentGroup.changeset
    instrument_group2b = %InstrumentGroup{
      name: "A config group",
      configuration_blob: "{some: 'config'}",
      facility: facility2
    } |> InstrumentGroup.changeset
    instrument_group3b = %InstrumentGroup{
      name: "Another config group",
      configuration_blob: "{some: 'config'}",
      facility: facility2
    } |> InstrumentGroup.changeset

    assert {:ok, _changeset} = Repo.insert instrument_group1b
    assert {:error, _changeset} = Repo.insert instrument_group2b
    assert {:ok, _changeset} = Repo.insert instrument_group3b
  end

end
