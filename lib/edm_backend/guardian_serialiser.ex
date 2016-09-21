defmodule EdmBackend.GuardianSerialiser do
  @behaviour Guardian.Serializer

  alias EdmBackend.Repo
  alias EdmBackend.User
  alias EdmBackend.Client

  def for_token(user = %User{}) do
    {:ok, "User:#{user.id}"}
  end

  def for_token(client = %Client{}) do
    {:ok, "Client:#{client.id}"}
  end

  def for_token(_) do
    {:error, "Unknown resource type"}
  end

  def from_token("User:" <> id) do
    {:ok, Repo.get(User, String.to_integer(id))}
  end

  def from_token("Client:" <> id) do
    {:ok, Repo.get(Client, String.to_integer(id))}
  end

  def from_token(_) do
    {:error, "Unknown resource type"}
  end
end
