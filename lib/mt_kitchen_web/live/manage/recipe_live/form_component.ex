defmodule MTKitchenWeb.Manage.RecipeLive.FormComponent do
  use MTKitchenWeb, :live_component

  alias MTKitchen.Management

  on_mount MTKitchenWeb.UserLiveAuth

  @impl true
  def update(%{recipe: recipe} = assigns, socket) do
    changeset = Management.change_recipe(recipe)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"recipe" => recipe_params}, socket) do
    changeset =
      socket.assigns.recipe
      |> Management.change_recipe(recipe_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"recipe" => recipe_params}, socket) do
    save_recipe(socket, socket.assigns.action, recipe_params)
  end

  #  def handle_event("change-primary-picture", params, socket) do
  #    {:noreply, push_event(socket, "sync-primary-picture", %{})}
  #  end

  defp save_recipe(socket, :edit, recipe_params) do
    current_user = socket.assigns.current_user
    recipe = socket.assigns.recipe

    with :ok <- Bodyguard.permit!(Management, :update_recipe, current_user, recipe),
         {:ok, recipe} do
      case Management.update_recipe(recipe, recipe_params) do
        {:ok, recipe} ->
          {
            :noreply,
            socket
            |> put_flash(:info, "Recipe updated successfully.")
            |> push_redirect(to: Routes.manage_recipe_path(socket, :show, recipe.slug))
          }

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    end
  end

  defp save_recipe(socket, :new, params) do
    current_user = socket.assigns.current_user
    authenticated_recipe_params = authenticated_params(params, current_user)

    case Management.create_recipe(authenticated_recipe_params) do
      {:ok, recipe} ->
        {:noreply,
         socket
         |> put_flash(:info, "Recipe created successfully.")
         |> push_redirect(to: Routes.manage_recipe_path(socket, :show, recipe.slug))}

      {:error, _recipe, %Ecto.Changeset{} = changeset, _current_changes} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp authenticated_params(recipe_params, current_user) do
    Map.put(recipe_params, "user_id", current_user.id)
  end
end
