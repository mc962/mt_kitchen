defmodule MTKitchenWeb.Manage.UserLive.Index do
  use MTKitchenWeb, :live_view

  on_mount MTKitchenWeb.UserLiveAuth

  # TODO authorize admins only

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    _current_user = socket.assigns.current_user

    users = MTKitchen.Accounts.list_users()

    {:noreply,
     socket
     |> assign(:page_title, "Show User")
     |> assign(:users, users)}
  end

  #  @impl true
  #  def handle_event("delete", %{"id" => id}, socket) do
  #    current_user = socket.assigns.current_user
  #
  #    recipe = Management.get_recipe!(id)
  #    {:ok, _} = Management.delete_recipe(recipe)
  #
  #    {:noreply, assign(socket, :recipes, Management.list_owned_recipes(current_user.id))}
  #  end
end
