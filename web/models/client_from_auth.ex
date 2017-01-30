defmodule EdmBackend.ClientFromAuth do
  @moduledoc """
  Retrieve the client information from an auth request
  """

  alias Ueberauth.Auth
  alias EdmBackend.Client
  require Logger

  @doc """
  Creates or retrieves a user based on credentials returned from Ueberauth
  """
  def find_or_create(%Auth{provider: provider, credentials: credentials} = auth) do
    Logger.debug "This is the auth data, provided by #{provider}:"
    Logger.debug inspect(auth)

    client_info = basic_info(auth)

    Client.get_or_create(provider, client_info, Map.from_struct(credentials))
  end

  # extracts some basic properties from the auth struct
  defp basic_info(auth) do
    %{id: auth.uid, name: name_from_auth(auth), avatar: auth.info.image, email: auth.info.email}
  end

  # Extracts or derives a name for the user
  defp name_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      name = [auth.info.first_name, auth.info.last_name]
      |> Enum.filter(&(&1 != nil and &1 != ""))

      cond do
        length(name) == 0 -> auth.info.nickname
        true -> Enum.join(name, " ")
      end
    end
  end
end
