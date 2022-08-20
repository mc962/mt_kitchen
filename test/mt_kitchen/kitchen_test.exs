defmodule MTKitchen.KitchenTest do
  use MTKitchen.DataCase

  alias MTKitchen.Kitchen

  describe "recipes" do
    alias MTKitchen.Kitchen.Recipe

    import MTKitchen.KitchenFixtures

    @invalid_attrs %{}

    test "list_recipes/0 returns all recipes" do
      recipe = recipe_fixture()
      assert Kitchen.list_recipes() == [recipe]
    end

    test "get_recipe!/1 returns the recipe with given id" do
      recipe = recipe_fixture()
      assert Kitchen.get_recipe!(recipe.id) == recipe
    end

    test "create_recipe/1 with valid data creates a recipe" do
      valid_attrs = %{}

      assert {:ok, %Recipe{} = recipe} = Kitchen.create_recipe(valid_attrs)
    end

    test "create_recipe/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Kitchen.create_recipe(@invalid_attrs)
    end

    test "update_recipe/2 with valid data updates the recipe" do
      recipe = recipe_fixture()
      update_attrs = %{}

      assert {:ok, %Recipe{} = recipe} = Kitchen.update_recipe(recipe, update_attrs)
    end

    test "update_recipe/2 with invalid data returns error changeset" do
      recipe = recipe_fixture()
      assert {:error, %Ecto.Changeset{}} = Kitchen.update_recipe(recipe, @invalid_attrs)
      assert recipe == Kitchen.get_recipe!(recipe.id)
    end

    test "delete_recipe/1 deletes the recipe" do
      recipe = recipe_fixture()
      assert {:ok, %Recipe{}} = Kitchen.delete_recipe(recipe)
      assert_raise Ecto.NoResultsError, fn -> Kitchen.get_recipe!(recipe.id) end
    end

    test "change_recipe/1 returns a recipe changeset" do
      recipe = recipe_fixture()
      assert %Ecto.Changeset{} = Kitchen.change_recipe(recipe)
    end
  end
end
