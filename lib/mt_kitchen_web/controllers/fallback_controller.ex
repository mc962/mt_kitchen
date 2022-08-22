defmodule MTKitchenWeb.FallbackController do
  use MTKitchenWeb, :controller

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:forbidden)
    |> put_view(MTKitchenWeb.ErrorView)
    |> render(:"403")
  end
end