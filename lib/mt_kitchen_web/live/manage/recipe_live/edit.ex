defmodule MTKitchenWeb.Manage.RecipeLive.Edit do
  use MTKitchenWeb, :live_view

  alias MTKitchen.Management
  alias MTKitchen.Management.Recipe

  on_mount MTKitchenWeb.UserLiveAuth

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:recipe, %Recipe{})}
  end

  #  def update(%{uploaded_files: uploads}, socket) do
  #    socket = assign(socket, :uploaded_files, uploads)
  #    {:ok, socket}
  #  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    current_user = socket.assigns.current_user
    recipe = Management.get_full_recipe!(id)

    with :ok <- Bodyguard.permit!(Management, :get_full_recipe!, current_user, recipe),
         {:ok, recipe} do
      socket
      |> assign(:page_title, "Edit Recipe")
      |> assign(:recipe, recipe)
    end
  end
end
