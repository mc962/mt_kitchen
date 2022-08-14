defmodule MTKitchenWeb.StepController do
  use MTKitchenWeb, :controller

  alias MTKitchen.Management

  def edit(conn, %{"id" => id}) do
    recipe = Management.get_full_recipe!(id)
    changeset = Management.change_recipe_steps(recipe)
    render(conn, "edit.html", recipe: recipe, changeset: changeset)
  end

  def update(conn, %{"id" => id, "recipe" => recipe_params}) do
    recipe = Management.get_full_recipe!(id)

    case Management.update_recipe_steps(recipe, recipe_params) do
      {:ok, recipe} ->
        conn
        |> put_flash(:info, "Recipe updated successfully.")
        |> redirect(to: Routes.recipe_steps_path(conn, :edit, recipe))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", recipe: recipe, changeset: changeset)
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