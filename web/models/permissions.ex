defimpl Canada.Can, for: EdmBackend.Client do
    alias EdmBackend.Client
    alias EdmBackend.Credential
    alias EdmBackend.Role
    alias EdmBackend.Ownership
    alias EdmBackend.Repo
    alias EdmBackend.Source

    @roles %{
      admin: [:view, :update, :create, :delete],
      viewer: [:view]
    }

    def can?(%Client{id: id}, :view, %Client{id: id}) do
      # Any client can view itself
      true
    end

    def can?(%Client{id: id} = client, action, source = %Source{}) when action in [:view, :update, :create, :delete] do
      # Client can manipulate its own sources
      %Client{id: owner_id} = source |> Repo.preload(:owner) |> Map.get(:owner)
      if id == owner_id do
        true
      else
        can?(client, action, source)
      end
    end

    def can?(client, action, subject) do
      Enum.any?(@roles, fn {role, permissions} ->
        action in permissions and Role.has_role?(role, client, subject)
      end)
    end

end
