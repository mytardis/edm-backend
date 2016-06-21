defmodule EdmBackend.Router do
  use EdmBackend.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug EdmBackend.RemoteIp
  end

  scope "/", EdmBackend do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api/v1/", EdmBackend do
    pipe_through :api

    resources "/client/", V1.ClientRegistrationController, only: [:create, :index]

  end

end
