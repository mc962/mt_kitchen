defmodule MTKitchenWeb.Manage.StepIngredientLive.FormComponent do
  use MTKitchenWeb, :live_component

  alias MTKitchen.Management

  on_mount MTKitchenWeb.UserLiveAuth

  # TODO hook this up properly to liveview, as it tends to unfocus the textarea after adding el to frontend

  @impl true
  def update(%{step: step} = assigns, socket) do
    changeset = Management.change_step_ingredients(step)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"step" => step_params}, socket) do
    changeset =
      socket.assigns.step
      |> Management.change_step_ingredients(step_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"step" => step_params}, socket) do
    save_step_ingredients(socket, socket.assigns.action, step_params)
  end

  defp save_step_ingredients(socket, :edit, step_params) do
    case Management.update_step_ingredients(socket.assigns.step, step_params) do
      {:ok, step} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Recipe updated successfully.")
          |> push_redirect(
            to:
              Routes.manage_step_ingredients_path(
                socket,
                :edit,
                socket.assigns.step.recipe.slug,
                step
              )
          )
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
