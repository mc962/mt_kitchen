defmodule MTKitchen.KitchenFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MTKitchen.Kitchen` context.
  """

  @doc """
  Generate a recipe.
  """
  def recipe_fixture(attrs \\ %{}) do
    {:ok, recipe} =
      attrs
      |> Enum.into(%{})
      |> MTKitchen.Kitchen.create_recipe()

    recipe
  end
end
