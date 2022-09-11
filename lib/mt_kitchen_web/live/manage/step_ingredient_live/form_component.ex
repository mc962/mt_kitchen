defmodule MTKitchenWeb.Manage.StepIngredientLive.FormComponent do
  use MTKitchenWeb, :live_component

  alias MTKitchen.Management
  alias MTKitchen.Management.StepIngredient
  alias MTKitchen.Management.Ingredient

  on_mount MTKitchenWeb.UserLiveAuth

  @impl true
  def update(%{step: step} = assigns, socket) do
    changeset = Management.change_step_ingredients(step)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("add-new-step-ingredient", _, socket) do
    # TODO figure out why error tags on nested resources don't get cleared when setting a brand new item
    existing_step_ingredients =
      Map.get(
        socket.assigns.changeset.changes,
        :step_ingredients,
        socket.assigns.step.step_ingredients
      )

    step_ingredients =
      existing_step_ingredients
      |> Enum.concat([
        Management.change_step_ingredient(%StepIngredient{
          temp_id: get_temp_id(),
          ingredient: %Ingredient{}
        })
      ])

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:step_ingredients, step_ingredients)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("remove-new-step-ingredient", %{"remove" => remove_id}, socket) do
    step_ingredients =
      socket.assigns.changeset.changes.step_ingredients
      |> Enum.reject(fn %{data: step_ingredient} ->
        step_ingredient.temp_id == remove_id
      end)

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:step_ingredients, step_ingredients)

    {:noreply, assign(socket, changeset: changeset)}
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
    current_user = socket.assigns.current_user
    step = socket.assigns.step
    authenticated_step_params = authenticated_params(step_params, current_user)

    with :ok <- Bodyguard.permit!(Management, :update_step_ingredients, current_user, step),
         {:ok, step} do
      case Management.update_step_ingredients(socket.assigns.step, authenticated_step_params) do
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

  defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)

  defp authenticated_params(step_params, current_user) do
    new_step_ingredients =
      step_params
      |> Map.get("step_ingredients")
      |> Enum.reduce(%{}, fn {input_id, step_ingredient}, acc ->
        new_ingredient =
          step_ingredient
          |> Map.get("ingredient")
          |> case do
            nil -> nil
            ingredient -> Map.put(ingredient, "user_id", current_user.id)
          end

        new_step_ingredient = Map.put(step_ingredient, "ingredient", new_ingredient)
        Map.put(acc, input_id, new_step_ingredient)
      end)

    Map.put(step_params, "step_ingredients", new_step_ingredients)
  end
end
