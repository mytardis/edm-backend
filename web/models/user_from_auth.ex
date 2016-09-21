defmodule EdmBackend.UserFromAuth do
  @moduledoc """
  Retrieve the user information from an auth request
  """

  alias Ueberauth.Auth
  alias EdmBackend.User
  require Logger

  def find_or_create(%Auth{provider: provider, credentials: credentials} = auth) do
    Logger.debug "This is the auth data, provided by #{provider}:"
    Logger.debug inspect(auth)

    user_info = basic_info(auth)

    User.get_or_create(provider, user_info, credentials)
  end

  defp basic_info(auth) do
    %{id: auth.uid, name: name_from_auth(auth), avatar: auth.info.image, email: auth.info.email}
  end

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
