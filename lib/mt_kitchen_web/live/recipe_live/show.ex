defmodule MTKitchenWeb.RecipeLive.Show do
  use MTKitchenWeb, :live_view

  alias MTKitchen.Management
  alias MTKitchen.Accounts

  @impl true
  def mount(_params, session, socket) do
    user_session_token = Map.get(session, "user_token")

    current_user =
      if user_session_token do
        Accounts.get_user_by_session_token(user_session_token)
      else
        nil
      end

    {:ok, socket |> assign(:current_user, current_user)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    current_user = socket.assigns.current_user

    current_user_id =
      if current_user do
        current_user.id
      else
        nil
      end

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:recipe, Management.get_full_public_recipe!(id, current_user_id))}
  end

  def step_ingredient_list_name(step_ingredient) do
    [step_ingredient.ingredient.name, step_ingredient.condition]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(", ")
  end

  defp page_title(:show), do: "Show Recipe"
  defp page_title(:edit), do: "Edit Recipe"
end
