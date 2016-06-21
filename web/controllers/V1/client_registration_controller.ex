defmodule EdmBackend.V1.ClientRegistrationController do
  use EdmBackend.Web, :controller
  alias EdmBackend.Client

  plug :put_view, EdmBackend.V1.ApiView

  #def get_token(conn, params) do
  #    Logger.debug inspect(conn)
  #    claims = %{"uuid" => params["uuid"],
  #      "remote_ip" => conn.assigns[:remote_ip]}
  #    token = claims |> token() |> with_signer(get_signer) |> sign() |>
  #    get_compact()
  #    conn |> assign(:token, token) |> render "token.json"
  #end

  def create(conn, %{"uuid" => uuid}) do
    new_client = %{uuid: uuid, ip_address: conn.assigns[:remote_ip]}

    changeset = Client.changeset(%Client{}, new_client)
    case Repo.insert(changeset) do
      {:ok, client} ->
        conn |> send_resp(201, "")
      {:error, changeset} ->
        render(conn, "error.json", changeset: changeset)
    end

  end
end
