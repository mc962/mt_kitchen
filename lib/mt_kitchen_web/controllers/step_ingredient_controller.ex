defmodule MTKitchenWeb.StepIngredientController do
  use MTKitchenWeb, :controller

  alias MTKitchen.Management

  def edit(conn, %{"id" => id}) do
    step = Management.get_full_step!(id)
    changeset = Management.change_step_ingredients(step)
    render(conn, "edit.html", step: step, changeset: changeset)
  end

  def update(conn, %{"recipe_id" => _recipe_id, "id" => id, "step" => step_params}) do
    current_user = conn.assigns.current_user
    step = Management.get_full_step!(id)

    authenticated_step_params = authenticated_params(step_params, current_user)
    case Management.update_step_ingredients(step, authenticated_step_params) do
      {:ok, step} ->
        conn
        |> put_flash(:info, "Step Ingredients updated successfully.")
        |> redirect(to: Routes.step_ingredients_path(conn, :edit, step.recipe, step))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", step: step, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    step = Management.get_full_step!(id)
    {:ok, _recipe} = Management.delete_step(step)

    conn
    |> put_flash(:info, "Step deleted successfully.")
    |> redirect(to: Routes.recipe_steps_path(conn, :edit, step.recipe))
  end

  defp authenticated_params(step_params, current_user) do
    new_step_ingredients =
      step_params
      |> Map.get("step_ingredients")
      |> Enum.reduce(%{}, fn ({input_id, step_ingredient}, acc) ->
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