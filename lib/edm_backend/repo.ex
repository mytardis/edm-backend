defmodule EdmBackend.Repo do
  use Ecto.Repo, otp_app: :edm_backend

  def init(type, opts) do
    url = System.get_env("DATABASE_URL") ||
          Application.get_env(:edm_backend, EdmBackend.Repo)[:url]
    opts = [url: url] ++ opts
    {:ok, opts}
  end
end
