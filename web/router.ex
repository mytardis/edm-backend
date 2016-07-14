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
    plug EdmBackend.Plug.RemoteIp
  end

  scope "/", EdmBackend do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/auth", EdmBackend do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  # Other scopes may use custom stacks.
  scope "/api/v1/" do
    pipe_through :api

    get "/graphql", GraphQL.Plug, schema: {EdmBackend.GraphQL.Schema, :schema}
    post "/graphql", GraphQL.Plug, schema: {EdmBackend.GraphQL.Schema, :schema}

    resources "/client/", EdmBackend.V1.ClientRegistrationController, only: [:create, :index]

  end

end
