defimpl Canada.Can, for: EdmBackend.Client do
    alias EdmBackend.Repo
    alias EdmBackend.Client
    alias EdmBackend.Role
    alias EdmBackend.Source
    alias EdmBackend.File

    @roles %{
      admin: [:view, :update, :create, :delete],
      viewer: [:view]
    }

    @doc """
    All clients can view and update themselves
    """
    def can?(%Client{id: id}, action, %Client{id: id}) when action in [:view, :update] do
      # Any client can view and update itself
      true
    end

    @doc """
    All clients can fully manage their own sources
    """
    def can?(%Client{id: id} = client, action, source = %Source{}) when action in [:view, :update, :create, :delete] do
      # Client can manipulate its own sources
      %Client{id: owner_id} = source |> Repo.preload(:owner) |> Map.get(:owner)
      if id == owner_id do
        true
      else
        can_default?(client, action, source)
      end
    end

    def can?(client, action, file = %File{}) when action in [:view, :update, :create, :delete] do
      source = file |> Repo.preload(:source) |> Map.get(:source)
      can?(client, action, source)
    end

    @doc """
    Any client can impersonate itself (i.e. generate tokens for itself)
    """
    def can?(%Client{id: id}, :impersonate, %Client{id: id}) do
      # Any client can be itself!
      true
    end

    @doc """
    Any client that has an admin role can impersonate (i.e. generate tokens for)
    another client
    """
    def can?(%Client{} = client, :impersonate, %Client{} = subject) do
      # Admins can impersonate other clients
      Role.has_role?(:admin, client, subject)
    end

    @doc """
    Any client with the appropriate role can perform the given action on the
    subject
    """
    def can?(client, action, subject) do
      can_default?(client, action, subject)
    end

    # Fallback permissions check
    defp can_default?(client, action, subject) do
      Enum.any?(@roles, fn {role, permissions} ->
        action in permissions and Role.has_role?(role, client, subject)
      end)
    end

end
