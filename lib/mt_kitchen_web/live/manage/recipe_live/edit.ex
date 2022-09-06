defmodule MTKitchenWeb.Manage.RecipeLive.Edit do
  use MTKitchenWeb, :live_view

  alias MTKitchen.Management
  alias MTKitchen.Management.Recipe

  on_mount MTKitchenWeb.UserLiveAuth

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :recipe, %Recipe{})}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "New Recipe")
    |> assign(:recipe, Management.get_full_recipe!(id))
  end
end
