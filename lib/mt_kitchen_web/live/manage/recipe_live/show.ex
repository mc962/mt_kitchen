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
    current_user = socket.assigns.current_user
    recipe = Management.get_full_recipe!(id)

    with :ok <- Bodyguard.permit!(Management, :get_full_recipe!, current_user, recipe),
         {:ok, recipe} do
      {:noreply,
       socket
       |> assign(:page_title, "Show Recipe")
       |> assign(:recipe, recipe)}
    end
  end
end
