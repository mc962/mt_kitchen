defmodule MTKitchenWeb.UserController do
  use MTKitchenWeb, :controller

  def show(conn, _params) do
    current_user = conn.assigns.current_user

    user_recipes = MTKitchen.Accounts.get_user_recipes(current_user.id)
    render(conn, "show.html", user: current_user, recipes: user_recipes)
  end
end
