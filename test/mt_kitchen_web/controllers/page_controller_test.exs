defmodule MTKitchenWeb.PageControllerTest do
  use MTKitchenWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to M and T's Kitchen</h1>"
  end
end
