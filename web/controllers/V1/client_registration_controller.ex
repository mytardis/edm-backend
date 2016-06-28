defmodule EdmBackend.V1.ClientRegistrationController do
  @moduledoc """
  Manages client registration requests
  """

  use EdmBackend.Web, :controller
  alias EdmBackend.Client
  import EdmBackend.TokenSigner
  require Logger

  plug EdmBackend.Plug.TokenAuth, [claims: [role: "uploader"]] when not action in [:create]

  @doc """
  Registers an uploader, issuing a signed token locked to the client's UUID
  and IP address
  """
  def create(conn, %{"uuid" => uuid}) do
    new_client = %{uuid: uuid, ip_address: conn.assigns[:remote_ip]}

    changeset = Client.changeset(%Client{}, new_client)

    case Repo.insert(changeset) do
      {:ok, client} ->
        conn |> add_token(client) |> render("create.json")
      {:error, changeset} ->
        render(conn, EdmBackend.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def index(conn, _params) do
    render conn, "index.json"
  end

end
