defmodule MTKitchenWeb.RecipeLive.Show do
  use MTKitchenWeb, :live_view

  alias MTKitchen.Management

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:recipe, Management.get_full_recipe!(id))}
  end

  def step_ingredient_list_name(step_ingredient) do
    [step_ingredient.ingredient.name, step_ingredient.condition]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(", ")
  end

  defp page_title(:show), do: "Show Recipe"
  defp page_title(:edit), do: "Edit Recipe"
end
