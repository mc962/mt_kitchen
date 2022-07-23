defmodule MTKitchenWeb.PageController do
  use MTKitchenWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
