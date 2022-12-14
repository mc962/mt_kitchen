defmodule MTKitchenWeb.RecipeLive.Index do
  use MTKitchenWeb, :live_view

  alias MTKitchen.Management

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :recipes, directory_recipes())}
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

  defp directory_recipes do
    Management.directory_recipes()
  end
end
