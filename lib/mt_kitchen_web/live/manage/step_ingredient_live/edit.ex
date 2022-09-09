defmodule MTKitchenWeb.Manage.StepIngredientLive.Edit do
  use MTKitchenWeb, :live_view

  alias MTKitchen.Management
  alias MTKitchen.Management.Step

  on_mount MTKitchenWeb.UserLiveAuth

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :step, %Step{})}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    current_user = socket.assigns.current_user
    step = Management.get_full_step!(id)

    with :ok <- Bodyguard.permit!(Management, :get_full_step!, current_user, step),
         {:ok, step} do
      socket
      |> assign(:page_title, "Edit Recipe")
      |> assign(:step, step)
    end
  end
end
