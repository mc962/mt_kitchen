defmodule MTKitchenWeb.Manage.RecipeLive.Index do
  use MTKitchenWeb, :live_view

  alias MTKitchen.Management

  on_mount MTKitchenWeb.UserLiveAuth

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :recipes, owned_recipes(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Recipes")
    |> assign(:recipe, nil)
  end

  defp owned_recipes(current_user) do
    Management.list_owned_recipes(current_user.id)
  end
end
