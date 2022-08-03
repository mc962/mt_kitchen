defmodule MTKitchen.ManagementTest do
  use MTKitchen.DataCase

  alias MTKitchen.Management

  describe "recipes" do
    alias MTKitchen.Management.Recipe

    import MTKitchen.ManagementFixtures

    @invalid_attrs %{description: nil, name: nil, publicly_accessible: nil, slug: nil}

    test "list_recipes/0 returns all recipes" do
      recipe = recipe_fixture()
      assert Management.list_recipes() == [recipe]
    end

    test "get_recipe!/1 returns the recipe with given id" do
      recipe = recipe_fixture()
      assert Management.get_recipe!(recipe.id) == recipe
    end

    test "create_recipe/1 with valid data creates a recipe" do
      valid_attrs = %{description: "some description", name: "some name", publicly_accessible: true, slug: "some slug"}

      assert {:ok, %Recipe{} = recipe} = Management.create_recipe(valid_attrs)
      assert recipe.description == "some description"
      assert recipe.name == "some name"
      assert recipe.publicly_accessible == true
      assert recipe.slug == "some slug"
    end

    test "create_recipe/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Management.create_recipe(@invalid_attrs)
    end

    test "update_recipe/2 with valid data updates the recipe" do
      recipe = recipe_fixture()
      update_attrs = %{description: "some updated description", name: "some updated name", publicly_accessible: false, slug: "some updated slug"}

      assert {:ok, %Recipe{} = recipe} = Management.update_recipe(recipe, update_attrs)
      assert recipe.description == "some updated description"
      assert recipe.name == "some updated name"
      assert recipe.publicly_accessible == false
      assert recipe.slug == "some updated slug"
    end

    test "update_recipe/2 with invalid data returns error changeset" do
      recipe = recipe_fixture()
      assert {:error, %Ecto.Changeset{}} = Management.update_recipe(recipe, @invalid_attrs)
      assert recipe == Management.get_recipe!(recipe.id)
    end

    test "delete_recipe/1 deletes the recipe" do
      recipe = recipe_fixture()
      assert {:ok, %Recipe{}} = Management.delete_recipe(recipe)
      assert_raise Ecto.NoResultsError, fn -> Management.get_recipe!(recipe.id) end
    end

    test "change_recipe/1 returns a recipe changeset" do
      recipe = recipe_fixture()
      assert %Ecto.Changeset{} = Management.change_recipe(recipe)
    end
  end

  describe "steps" do
    alias MTKitchen.Management.Step

    import MTKitchen.ManagementFixtures

    @invalid_attrs %{instruction: nil, order: nil}

    test "list_steps/0 returns all steps" do
      step = step_fixture()
      assert Management.list_steps() == [step]
    end

    test "get_step!/1 returns the step with given id" do
      step = step_fixture()
      assert Management.get_step!(step.id) == step
    end

    test "create_step/1 with valid data creates a step" do
      valid_attrs = %{instruction: "some instruction", order: 42}

      assert {:ok, %Step{} = step} = Management.create_step(valid_attrs)
      assert step.instruction == "some instruction"
      assert step.order == 42
    end

    test "create_step/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Management.create_step(@invalid_attrs)
    end

    test "update_step/2 with valid data updates the step" do
      step = step_fixture()
      update_attrs = %{instruction: "some updated instruction", order: 43}

      assert {:ok, %Step{} = step} = Management.update_step(step, update_attrs)
      assert step.instruction == "some updated instruction"
      assert step.order == 43
    end

    test "update_step/2 with invalid data returns error changeset" do
      step = step_fixture()
      assert {:error, %Ecto.Changeset{}} = Management.update_step(step, @invalid_attrs)
      assert step == Management.get_step!(step.id)
    end

    test "delete_step/1 deletes the step" do
      step = step_fixture()
      assert {:ok, %Step{}} = Management.delete_step(step)
      assert_raise Ecto.NoResultsError, fn -> Management.get_step!(step.id) end
    end

    test "change_step/1 returns a step changeset" do
      step = step_fixture()
      assert %Ecto.Changeset{} = Management.change_step(step)
    end
  end

  describe "ingredients" do
    alias MTKitchen.Management.Ingredient

    import MTKitchen.ManagementFixtures

    @invalid_attrs %{ancestry: nil, description: nil, name: nil, slug: nil}

    test "list_ingredients/0 returns all ingredients" do
      ingredient = ingredient_fixture()
      assert Management.list_ingredients() == [ingredient]
    end

    test "get_ingredient!/1 returns the ingredient with given id" do
      ingredient = ingredient_fixture()
      assert Management.get_ingredient!(ingredient.id) == ingredient
    end

    test "create_ingredient/1 with valid data creates a ingredient" do
      valid_attrs = %{ancestry: "some ancestry", description: "some description", name: "some name", slug: "some slug"}

      assert {:ok, %Ingredient{} = ingredient} = Management.create_ingredient(valid_attrs)
      assert ingredient.ancestry == "some ancestry"
      assert ingredient.description == "some description"
      assert ingredient.name == "some name"
      assert ingredient.slug == "some slug"
    end

    test "create_ingredient/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Management.create_ingredient(@invalid_attrs)
    end

    test "update_ingredient/2 with valid data updates the ingredient" do
      ingredient = ingredient_fixture()
      update_attrs = %{ancestry: "some updated ancestry", description: "some updated description", name: "some updated name", slug: "some updated slug"}

      assert {:ok, %Ingredient{} = ingredient} = Management.update_ingredient(ingredient, update_attrs)
      assert ingredient.ancestry == "some updated ancestry"
      assert ingredient.description == "some updated description"
      assert ingredient.name == "some updated name"
      assert ingredient.slug == "some updated slug"
    end

    test "update_ingredient/2 with invalid data returns error changeset" do
      ingredient = ingredient_fixture()
      assert {:error, %Ecto.Changeset{}} = Management.update_ingredient(ingredient, @invalid_attrs)
      assert ingredient == Management.get_ingredient!(ingredient.id)
    end

    test "delete_ingredient/1 deletes the ingredient" do
      ingredient = ingredient_fixture()
      assert {:ok, %Ingredient{}} = Management.delete_ingredient(ingredient)
      assert_raise Ecto.NoResultsError, fn -> Management.get_ingredient!(ingredient.id) end
    end

    test "change_ingredient/1 returns a ingredient changeset" do
      ingredient = ingredient_fixture()
      assert %Ecto.Changeset{} = Management.change_ingredient(ingredient)
    end
  end

  describe "step_ingredients" do
    alias MTKitchen.Management.StepIngredient

    import MTKitchen.ManagementFixtures

    @invalid_attrs %{amount: nil, condition: nil, unit: nil}

    test "list_step_ingredients/0 returns all step_ingredients" do
      step_ingredient = step_ingredient_fixture()
      assert Management.list_step_ingredients() == [step_ingredient]
    end

    test "get_step_ingredient!/1 returns the step_ingredient with given id" do
      step_ingredient = step_ingredient_fixture()
      assert Management.get_step_ingredient!(step_ingredient.id) == step_ingredient
    end

    test "create_step_ingredient/1 with valid data creates a step_ingredient" do
      valid_attrs = %{amount: "120.5", condition: "some condition", unit: "some unit"}

      assert {:ok, %StepIngredient{} = step_ingredient} = Management.create_step_ingredient(valid_attrs)
      assert step_ingredient.amount == Decimal.new("120.5")
      assert step_ingredient.condition == "some condition"
      assert step_ingredient.unit == "some unit"
    end

    test "create_step_ingredient/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Management.create_step_ingredient(@invalid_attrs)
    end

    test "update_step_ingredient/2 with valid data updates the step_ingredient" do
      step_ingredient = step_ingredient_fixture()
      update_attrs = %{amount: "456.7", condition: "some updated condition", unit: "some updated unit"}

      assert {:ok, %StepIngredient{} = step_ingredient} = Management.update_step_ingredient(step_ingredient, update_attrs)
      assert step_ingredient.amount == Decimal.new("456.7")
      assert step_ingredient.condition == "some updated condition"
      assert step_ingredient.unit == "some updated unit"
    end

    test "update_step_ingredient/2 with invalid data returns error changeset" do
      step_ingredient = step_ingredient_fixture()
      assert {:error, %Ecto.Changeset{}} = Management.update_step_ingredient(step_ingredient, @invalid_attrs)
      assert step_ingredient == Management.get_step_ingredient!(step_ingredient.id)
    end

    test "delete_step_ingredient/1 deletes the step_ingredient" do
      step_ingredient = step_ingredient_fixture()
      assert {:ok, %StepIngredient{}} = Management.delete_step_ingredient(step_ingredient)
      assert_raise Ecto.NoResultsError, fn -> Management.get_step_ingredient!(step_ingredient.id) end
    end

    test "change_step_ingredient/1 returns a step_ingredient changeset" do
      step_ingredient = step_ingredient_fixture()
      assert %Ecto.Changeset{} = Management.change_step_ingredient(step_ingredient)
    end
  end
end
