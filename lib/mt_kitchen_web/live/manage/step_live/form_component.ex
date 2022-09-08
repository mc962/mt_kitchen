defmodule MTKitchenWeb.Manage.StepLive.FormComponent do
  use MTKitchenWeb, :live_component

  alias MTKitchen.Management

  on_mount MTKitchenWeb.UserLiveAuth

  # TODO hook this up properly to liveview, as it tends to unfocus the textarea after adding el to frontend

  @impl true
  def update(%{recipe: recipe} = assigns, socket) do
    changeset = Management.change_recipe_steps(recipe)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"recipe" => recipe_params}, socket) do
    changeset =
      socket.assigns.recipe
      |> Management.change_recipe_steps(recipe_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"recipe" => recipe_params}, socket) do
    save_recipe_steps(socket, socket.assigns.action, recipe_params)
  end

  defp save_recipe_steps(socket, :edit, recipe_params) do
    case Management.update_recipe(socket.assigns.recipe, recipe_params) do
      {:ok, recipe} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Recipe updated successfully.")
          |> push_redirect(to: Routes.manage_recipe_steps_path(socket, :edit, recipe.slug))
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
