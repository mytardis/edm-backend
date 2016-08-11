defmodule EdmBackend.Group do
  use EdmBackend.Web, :model

  schema "groups" do
    field :name, :string
    field :description, :string
    has_many :sub_groups, EdmBackend.Group, foreign_key: :parent_id
    belongs_to :parent, EdmBackend.Group, foreign_key: :parent_id
    timestamps
  end
end
