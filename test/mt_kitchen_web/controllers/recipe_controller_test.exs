defmodule MTKitchenWeb.RecipeControllerTest do
  use MTKitchenWeb.ConnCase

  import MTKitchen.ManagementFixtures

  @create_attrs %{description: "some description", name: "some name", publicly_accessible: true, slug: "some slug"}
  @update_attrs %{description: "some updated description", name: "some updated name", publicly_accessible: false, slug: "some updated slug"}
  @invalid_attrs %{description: nil, name: nil, publicly_accessible: nil, slug: nil}

  describe "index" do
    test "lists all recipes", %{conn: conn} do
      conn = get(conn, Routes.manage_recipe_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Recipes"
    end
  end

  describe "new recipe" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.manage_recipe_path(conn, :new))
      assert html_response(conn, 200) =~ "New Recipe"
    end
  end

  describe "create recipe" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.manage_recipe_path(conn, :create), recipe: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.manage_recipe_path(conn, :show, id)

      conn = get(conn, Routes.manage_recipe_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Recipe"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.manage_recipe_path(conn, :create), recipe: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Recipe"
    end
  end

  describe "edit recipe" do
    setup [:create_recipe]

    test "renders form for editing chosen recipe", %{conn: conn, recipe: recipe} do
      conn = get(conn, Routes.manage_recipe_path(conn, :edit, recipe))
      assert html_response(conn, 200) =~ "Edit Recipe"
    end
  end

  describe "update recipe" do
    setup [:create_recipe]

    test "redirects when data is valid", %{conn: conn, recipe: recipe} do
      conn = put(conn, Routes.manage_recipe_path(conn, :update, recipe), recipe: @update_attrs)
      assert redirected_to(conn) == Routes.manage_recipe_path(conn, :show, recipe)

      conn = get(conn, Routes.manage_recipe_path(conn, :show, recipe))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, recipe: recipe} do
      conn = put(conn, Routes.manage_recipe_path(conn, :update, recipe), recipe: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Recipe"
    end
  end

  describe "delete recipe" do
    setup [:create_recipe]

    test "deletes chosen recipe", %{conn: conn, recipe: recipe} do
      conn = delete(conn, Routes.manage_recipe_path(conn, :delete, recipe))
      assert redirected_to(conn) == Routes.manage_recipe_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.manage_recipe_path(conn, :show, recipe))
      end
    end
  end

  defp create_recipe(_) do
    recipe = recipe_fixture()
    %{recipe: recipe}
  end
end
