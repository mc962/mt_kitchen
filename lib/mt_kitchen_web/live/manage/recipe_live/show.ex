defmodule MTKitchenWeb.Manage.RecipeLive.Show do
  use MTKitchenWeb, :live_view

  alias MTKitchen.Management

  on_mount MTKitchenWeb.UserLiveAuth

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Show Recipe")
     |> assign(:recipe, Management.get_full_public_recipe!(id))}
  end
end
