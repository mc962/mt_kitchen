defmodule MTKitchenWeb.RecipeController do
  use MTKitchenWeb, :controller

  alias MTKitchen.Management
  alias MTKitchen.Management.Recipe

  def index(conn, _params) do
    recipes = Management.list_recipes()
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
        |> redirect(to: Routes.manage_recipe_path(conn, :show, recipe))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    recipe = Management.get_recipe!(id)
    render(conn, "show.html", recipe: recipe)
  end

  def edit(conn, %{"id" => id}) do
    recipe = Management.get_full_recipe!(id)
    changeset = Management.change_recipe(recipe)
    render(conn, "edit.html", recipe: recipe, changeset: changeset)
  end

  def update(conn, %{"id" => id, "recipe" => recipe_params}) do
    recipe = Management.get_full_recipe!(id)

    case Management.update_recipe(recipe, recipe_params) do
      {:ok, recipe} ->
        conn
        |> put_flash(:info, "Recipe updated successfully.")
        |> redirect(to: Routes.manage_recipe_path(conn, :show, recipe))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", recipe: recipe, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    recipe = Management.get_recipe!(id)
    {:ok, _recipe} = Management.delete_recipe(recipe)

    conn
    |> put_flash(:info, "Recipe deleted successfully.")
    |> redirect(to: Routes.manage_recipe_path(conn, :index))
  end

  defp authenticated_params(recipe_params, current_user) do
    Map.put(recipe_params, "user_id", current_user.id)
  end
end