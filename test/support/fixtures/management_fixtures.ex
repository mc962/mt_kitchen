defmodule MTKitchen.ManagementFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MTKitchen.Management` context.
  """

  @doc """
  Generate a unique recipe slug.
  """
  def unique_recipe_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a recipe.
  """
  def recipe_fixture(attrs \\ %{}) do
    {:ok, recipe} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        publicly_accessible: true,
        slug: unique_recipe_slug()
      })
      |> MTKitchen.Management.create_recipe()

    recipe
  end

  @doc """
  Generate a step.
  """
  def step_fixture(attrs \\ %{}) do
    {:ok, step} =
      attrs
      |> Enum.into(%{
        instruction: "some instruction",
        order: 42,
        recipe_id: Map.get(attrs, :recipe_id) || recipe_fixture().id
      })
      |> MTKitchen.Management.create_step()

    step
  end

  @doc """
  Generate a unique ingredient slug.
  """
  def unique_ingredient_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a ingredient.
  """
  def ingredient_fixture(attrs \\ %{}) do
    {:ok, ingredient} =
      attrs
      |> Enum.into(%{
        ancestry: "some ancestry",
        description: "some description",
        name: "some name",
        slug: unique_ingredient_slug()
      })
      |> MTKitchen.Management.create_ingredient()

    ingredient
  end

  #  @doc """
  #  Generate a step_ingredient.
  #  """
  #  def step_ingredient_fixture(attrs \\ %{}) do
  #    {:ok, step_ingredient} =
  #      attrs
  #      |> Enum.into(%{
  #        amount: "120.5",
  #        condition: "some condition",
  #        unit: "some unit"
  #      })
  #      |> MTKitchen.Management.create_step_ingredient()
  #
  #    step_ingredient
  #  end
end
