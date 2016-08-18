defmodule EdmBackend.FacilityModelTest do
  use EdmBackend.ModelCase
  alias EdmBackend.Facility

  test "valid facility values" do
    facility = %Facility{
      name: "test facility"
    } |> Facility.changeset
    assert facility.valid?
  end

  test "invalid facility values" do
    facility = %Facility{} |> Facility.changeset
    refute facility.valid?
  end

  test "facility uniqueness" do
    facility1 = %Facility{
      name: "test facility"
    } |> Facility.changeset
    facility2 = %Facility{
      name: "test facility"
    } |> Facility.changeset
    facility3 = %Facility{
      name: "another test facility"
    } |> Facility.changeset

    assert {:ok, _changeset} = Repo.insert facility1
    assert {:error, _changeset} = Repo.insert facility2
    assert {:ok, _changeset} = Repo.insert facility3
  end

end
