defmodule MTKitchenWeb.StepController do
  use MTKitchenWeb, :controller

  alias MTKitchen.Management

  def edit(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    recipe = Management.get_full_recipe!(id)

    with :ok <- Bodyguard.permit(Management, :get_full_recipe!, current_user, recipe),
         {:ok, recipe} do
      changeset = Management.change_recipe_steps(recipe)
      render(conn, "edit.html", recipe: recipe, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "recipe" => recipe_params}) do
    current_user = conn.assigns.current_user
    recipe = Management.get_full_recipe!(id)

    with :ok <- Bodyguard.permit(Management, :update_recipe_steps, current_user, recipe),
         {:ok, recipe} do
      case Management.update_recipe_steps(recipe, recipe_params) do
        {:ok, recipe} ->
          conn
          |> put_flash(:info, "Recipe updated successfully.")
          |> redirect(to: Routes.manage_recipe_steps_path(conn, :edit, recipe))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", recipe: recipe, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    step = Management.get_full_step!(id)

    with :ok <- Bodyguard.permit(Management, :delete_step, current_user, step),
         {:ok, step} do
      {:ok, _} = Management.delete_step(step)

      conn
      |> put_flash(:info, "Step deleted successfully.")
      |> redirect(to: Routes.manage_recipe_steps_path(conn, :edit, step.recipe))
    end
  end
end
