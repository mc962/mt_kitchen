defmodule MTKitchenWeb.PageController do
  use MTKitchenWeb, :controller

  def index(conn, _params) do
  conn
  |> render("index.html")
#  render(conn, "index.html")
  end
end
