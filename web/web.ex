defmodule EdmBackend.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use EdmBackend.Web, :controller
      use EdmBackend.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Schema
      use Calecto.Schema, usec: true

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      # Ensure uuid primary keys are used for all models
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      alias EdmBackend.Repo
      import Ecto
      import Ecto.Query

      import EdmBackend.Router.Helpers
      import EdmBackend.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2,
                                        view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import EdmBackend.Router.Helpers
      import EdmBackend.ErrorHelpers
      import EdmBackend.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias EdmBackend.Repo
      import Ecto
      import Ecto.Query
      import EdmBackend.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
