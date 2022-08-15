defmodule MTKitchenWeb.StepIngredientController do
  use MTKitchenWeb, :controller

  alias MTKitchen.Management

  def edit(conn, %{"id" => id}) do
    step = Management.get_full_step!(id)
    changeset = Management.change_step_ingredients(step)
    render(conn, "edit.html", step: step, changeset: changeset)
  end

  def update(conn, %{"recipe_id" => _recipe_id, "id" => id, "step" => step_params}) do
    step = Management.get_full_step!(id)

    case Management.update_step_ingredients(step, step_params) do
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
end