defmodule MTKitchenWeb.RecipeController do
  use MTKitchenWeb, :controller

  alias MTKitchen.Management
  alias MTKitchen.Management.Recipe

  action_fallback MTKitchenWeb.FallbackController

  def index(conn, _params) do
    current_user = conn.assigns.current_user

    recipes = Management.list_owned_recipes(current_user.id)
    render(conn, "index.html", recipes: recipes)
  end

  def new(conn, _params) do
    changeset = Management.change_recipe(%Recipe{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"recipe" => recipe_params}) do
    current_user = conn.assigns.current_user

    authenticated_recipe_params = authenticated_params(recipe_params, current_user)

    case Management.create_recipe(authenticated_recipe_params) do
      {:ok, recipe} ->
        conn
        |> put_flash(:info, "Recipe created successfully.")
        |> redirect(to: Routes.manage_recipe_path(conn, :show, recipe.slug))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    recipe = Management.get_recipe!(id)

    with :ok <- Bodyguard.permit(Management, :get_recipe!, current_user, recipe),
         {:ok, recipe} do
      render(conn, "show.html", recipe: recipe)
    end
  end

  def edit(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    recipe = Management.get_full_recipe!(id)

    with :ok <- Bodyguard.permit(Management, :get_full_recipe!, current_user, recipe),
         {:ok, recipe} do
      changeset = Management.change_recipe(recipe)

      render(conn, "edit.html", recipe: recipe, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "recipe" => recipe_params}) do
    current_user = conn.assigns.current_user
    recipe = Management.get_full_recipe!(id)

    with :ok <- Bodyguard.permit(Management, :update_recipe, current_user, recipe),
         {:ok, recipe} do
      case Management.update_recipe(recipe, recipe_params) do
        {:ok, recipe} ->
          conn
          |> put_flash(:info, "Recipe updated successfully.")
          |> redirect(to: Routes.manage_recipe_path(conn, :show, recipe.slug))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", recipe: recipe, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    recipe = Management.get_recipe!(id)

    with :ok <- Bodyguard.permit(Management, :delete_recipe, current_user, recipe),
         {:ok, recipe} do
      {:ok, _recipe} = Management.delete_recipe(recipe)

      conn
      |> put_flash(:info, "Recipe deleted successfully.")
      |> redirect(to: Routes.manage_recipe_path(conn, :index))
    end
  end

  defp authenticated_params(recipe_params, current_user) do
    Map.put(recipe_params, "user_id", current_user.id)
  end
end
