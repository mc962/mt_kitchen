defmodule MTKitchenWeb.Manage.StepLive.FormComponent do
  use MTKitchenWeb, :live_component

  alias MTKitchen.Management
  alias MTKitchen.Management.Step

  on_mount MTKitchenWeb.UserLiveAuth

  @impl true
  def update(%{recipe: recipe} = assigns, socket) do
    changeset = Management.change_recipe_steps(recipe)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("add-new-step", _, socket) do
    existing_steps =
      Map.get(socket.assigns.changeset.changes, :steps, socket.assigns.recipe.steps)

    steps =
      existing_steps
      |> Enum.concat([
        Management.change_step(%Step{
          temp_id: Management.get_temp_id(),
          order: length(existing_steps) + 1
        })
      ])

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:steps, steps)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("remove-new-step", %{"remove" => remove_id}, socket) do
    steps =
      socket.assigns.changeset.changes.steps
      |> Enum.reject(fn %{data: step} ->
        step.temp_id == remove_id
      end)

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:steps, steps)

    {:noreply, assign(socket, changeset: changeset)}
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
    current_user = socket.assigns.current_user
    recipe = socket.assigns.recipe

    with :ok <- Bodyguard.permit!(Management, :update_recipe_steps, current_user, recipe),
         {:ok, recipe} do
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
end
