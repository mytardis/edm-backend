defmodule EdmBackend.FacilityModelTest do
  use EdmBackend.ModelCase
  alias EdmBackend.Facility

  test "valid facility values" do
    facility = %Facility{} |> Facility.changeset(%{
      name: "test facility"
    })
    assert facility.valid?
  end

  test "invalid facility values" do
    facility = %Facility{} |> Facility.changeset
    refute facility.valid?
  end

  test "facility uniqueness" do
    facility1 = %Facility{} |> Facility.changeset(%{
      name: "test facility"
    })
    facility2 = %Facility{} |> Facility.changeset(%{
      name: "test facility"
    })
    facility3 = %Facility{} |> Facility.changeset(%{
      name: "another test facility"
    })

    assert {:ok, _changeset} = Repo.insert facility1
    assert {:error, _changeset} = Repo.insert facility2
    assert {:ok, _changeset} = Repo.insert facility3
  end

end
