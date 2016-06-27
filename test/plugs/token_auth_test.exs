defmodule EdmBackend.TokenAuthTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias EdmBackend.TokenSigner
  require Logger

  defmodule TokenAuthPlugRouter do
    use Plug.Router

    plug :match
    plug EdmBackend.Plug.RemoteIp
    plug EdmBackend.Plug.TokenAuth, [claims: [role: "uploader"]]
    plug :dispatch

    get "/validate_token" do
      conn |> put_resp_content_type("text/plain") |> send_resp(200, "ok!")
    end
  end

  test "token is successfully validated" do
    new_client = %{uuid: "ca5ef0f1-c9a5-4920-9cff-eacce728e8de",
      ip_address: "127.0.0.1",
      role: "uploader"}
    token = TokenSigner.sign_token(new_client)
    conn = conn(:get, "/validate_token")
      |> put_req_header("authorization", "Bearer " <> token)
      |> TokenAuthPlugRouter.call([])

    assert conn.status == 200
    assert conn.resp_body == "ok!"
  end

  test "token fails verification because IP address has changed" do
    new_client = %{uuid: "ca5ef0f1-c9a5-4920-9cff-eacce728e8de",
      ip_address: "127.0.1.1",
      role: "uploader"}
    token = TokenSigner.sign_token(new_client)
    conn = conn(:get, "/validate_token")
      |> put_req_header("authorization", "Bearer " <> token)
      |> TokenAuthPlugRouter.call([])

    assert conn.status == 401
    assert conn.resp_body == "Unauthorized"
  end

  test "token verification is skipped because claims already provided" do
    conn = conn(:get, "/validate_token")
      |> assign(:claims, %{uuid: "ca5ef0f1-c9a5-4920-9cff-eacce728e8de"})
      |> TokenAuthPlugRouter.call([])

    assert conn.status == 200
    assert conn.resp_body == "ok!"
  end
end
