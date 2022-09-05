defmodule MTKitchenWeb.Manage.UserLive.Show do
  use MTKitchenWeb, :live_view

  on_mount MTKitchenWeb.UserLiveAuth

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    current_user = socket.assigns.current_user

    user_recipes = MTKitchen.Accounts.get_user_recipes(current_user.id)

    {:noreply,
     socket
     |> assign(:page_title, "Show User")
     |> assign(:user, current_user)
     |> assign(:recipes, user_recipes)}
  end
end
