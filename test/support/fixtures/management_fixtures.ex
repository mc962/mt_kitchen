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
end
