defmodule EdmBackend.V1.ClientRegistrationView do

  def render("index.json", _assigns) do
    %{hello: "world"}
  end

  def render("create.json", assigns) do
    %{token: assigns.token}
  end
end
