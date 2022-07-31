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
end
