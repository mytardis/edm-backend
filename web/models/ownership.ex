alias EdmBackend.Repo

defprotocol EdmBackend.Ownership do
  @doc "Derives owner groups for the given database object"
  def of(data)
end

defimpl EdmBackend.Ownership, for: EdmBackend.Group do
  def of(group) do
    [group]
  end
end

defimpl EdmBackend.Ownership, for: EdmBackend.Host do
  def of(host) do
    [host |> Repo.preload(:group) |> Map.get(:group)]
  end
end

defimpl EdmBackend.Ownership, for: EdmBackend.Client do
  def of(client) do
    EdmBackend.Client.all_groups(client)
  end
end

defimpl EdmBackend.Ownership, for: EdmBackend.Source do
  def of(source) do
    EdmBackend.Ownership.of(source |> Repo.preload(:owner) |> Map.get(:owner))
  end
end

defimpl EdmBackend.Ownership, for: EdmBackend.Destination do
  def of(destination) do
    EdmBackend.Ownership.of(destination |> Repo.preload(:host) |> Map.get(:host))
  end
end

defimpl EdmBackend.Ownership, for: EdmBackend.File do
  def of(file) do
    EdmBackend.Ownership.of(file |> Repo.preload(:source) |> Map.get(:source))
  end
end

defimpl EdmBackend.Ownership, for: EdmBackend.FileTransfer do
  def of(file_transfer) do
    EdmBackend.Ownership.of(file_transfer |> Repo.preload(:file) |> Map.get(:file))
  end
end
