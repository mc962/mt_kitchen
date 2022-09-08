defmodule MTKitchen.Management do
  defdelegate authorize(action, user, params), to: MTKitchen.Management.Policy

  @moduledoc """
  The Management context.
  """

  import Ecto.Query, warn: false
  alias MTKitchen.Repo

  alias MTKitchen.Management.Recipe
  alias MtKitchenWeb.Uploaders.Image

  @doc """
  Returns the list of recipes.

  ## Examples

      iex> list_recipes()
      [%Recipe{}, ...]

  """
  def list_recipes do
    Repo.all(Recipe)
  end

  @doc """
  Returns the list of recipes displayed to the public
  """
  def directory_recipes do
    Repo.all(
      from r in Recipe,
        where: r.publicly_accessible == true
    )
  end

  @doc """
  Returns the list of recipes owned by the current user.

  ## Examples

      iex> list_owned_recipes()
      [%Recipe{}, ...]

  """
  def list_owned_recipes(user_id) do
    Repo.all(
      from r in Recipe,
        where: r.user_id == ^user_id
    )
  end

  @doc """
  Gets a single recipe.

  Raises `Ecto.NoResultsError` if the Recipe does not exist.

  ## Examples

      iex> get_recipe!(123)
      %Recipe{}

      iex> get_recipe!(456)
      ** (Ecto.NoResultsError)

  """
  def get_recipe!(id) do
    Repo.one!(
      from r in Recipe,
        where: r.slug == ^id
    )
  end

  @doc """
  Gets a single recipe, including associated resources needed for editing.

  Raises `Ecto.NoResultsError` if the Recipe does not exist.

  ## Examples

      iex> get_full_recipe!(123)
      %Recipe{}

      iex> get_full_recipe!(456)
      ** (Ecto.NoResultsError)

  """
  def get_full_recipe!(id) do
    Repo.one!(
      from r in Recipe,
        where: r.slug == ^id,
        preload: [:steps]
    )
  end

  def get_full_public_recipe!(id) do
    Repo.one!(
      from r in Recipe,
        where:
          r.slug == ^id and
            r.publicly_accessible == true,
        preload: [steps: [step_ingredients: [:ingredient]]]
    )
  end

  @doc """
  Creates a recipe.

  ## Examples

      iex> create_recipe(%{field: value})
      {:ok, %Recipe{}}

      iex> create_recipe(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_recipe(attrs \\ %{}) do
    %Recipe{}
    |> Recipe.information_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a recipe.

  ## Examples

      iex> update_recipe(recipe, %{field: new_value})
      {:ok, %Recipe{}}

      iex> update_recipe(recipe, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_recipe(%Recipe{} = recipe, attrs) do
    original_url = recipe.primary_picture

    result =
      recipe
      |> Recipe.information_changeset(attrs)
      |> Repo.update()

    case result do
      {:ok, recipe_result} ->
        # Only delete image url if recipe change was successful, and only do so if there was a change from some
        #   image url to something else
        if original_url && recipe_result.primary_picture != original_url do
          Image.delete({original_url, recipe_result})
        end

      {:err, changeset} ->
        changeset
    end

    result
  end

  @doc """
  Updates a recipe's steps.

  ## Examples

      iex> update_recipe_steps(recipe, %{field: new_value})
      {:ok, %Recipe{}}

      iex> update_recipe_steps(recipe, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_recipe_steps(%Recipe{} = recipe, attrs) do
    recipe
    |> Recipe.recipe_steps_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a recipe.

  ## Examples

      iex> delete_recipe(recipe)
      {:ok, %Recipe{}}

      iex> delete_recipe(recipe)
      {:error, %Ecto.Changeset{}}

  """
  def delete_recipe(%Recipe{} = recipe) do
    original_url = recipe.primary_picture

    result = Repo.delete(recipe)

    case result do
      {:ok, recipe_result} ->
        if original_url do
          # Only delete image url if recipe deletion was successful and only if the image url actually exists.
          # As the image has been deleted, we should always delete the image in this case.
          Image.delete({original_url, recipe_result})
        end

      {:err, changeset} ->
        changeset
    end

    result
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking recipe changes.

  ## Examples

      iex> change_recipe(recipe)
      %Ecto.Changeset{data: %Recipe{}}

  """
  def change_recipe(%Recipe{} = recipe, attrs \\ %{}) do
    Recipe.information_changeset(recipe, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking recipe steps changes.

  ## Examples

      iex> change_recipe_steps(recipe)
      %Ecto.Changeset{data: %Recipe{}}

  """
  def change_recipe_steps(%Recipe{} = recipe, attrs \\ %{}) do
    Recipe.recipe_steps_changeset(recipe, attrs)
  end

  alias MTKitchen.Management.Step

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking recipe step ingredients changes.

  ## Examples

      iex> change_step_ingredients(step)
      %Ecto.Changeset{data: %Step{}}

  """
  def change_step_ingredients(%Step{} = step, attrs \\ %{}) do
    Step.step_ingredients_changeset(step, attrs)
  end

  @doc """
  Returns the list of steps.

  ## Examples

      iex> list_steps()
      [%Step{}, ...]

  """
  def list_steps do
    Repo.all(Step)
  end

  @doc """
  Gets a single step.

  Raises `Ecto.NoResultsError` if the Step does not exist.

  ## Examples

      iex> get_step!(123)
      %Step{}

      iex> get_step!(456)
      ** (Ecto.NoResultsError)

  """
  def get_step!(id), do: Repo.get!(Step, id)

  @doc """
  Gets a single step with associated resources for full recipe management.

  Raises `Ecto.NoResultsError` if the Step does not exist.

  ## Examples

      iex> get_full_step!(123)
      %Step{}

      iex> get_full_step!(456)
      ** (Ecto.NoResultsError)

  """
  def get_full_step!(id) do
    Repo.one!(
      from s in Step,
        where: s.id == ^id,
        preload: [:recipe, step_ingredients: [:ingredient]]
    )
  end

  @doc """
  Creates a step.

  ## Examples

      iex> create_step(%{field: value})
      {:ok, %Step{}}

      iex> create_step(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_step(attrs \\ %{}) do
    %Step{}
    |> Step.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a step.

  @doc \"""
  Updates a recipe step's ingredients.

  ## Examples

      iex> update_step_ingredients(step, %{field: new_value})
      {:ok, %Recipe{}}

      iex> update_step_ingredients(step, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_step_ingredients(%Step{} = step, attrs) do
    step
    |> Step.step_ingredients_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a step.

  ## Examples

      iex> delete_step(step)
      {:ok, %Step{}}

      iex> delete_step(step)
      {:error, %Ecto.Changeset{}}

  """
  def delete_step(%Step{} = step) do
    Repo.delete(step)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking step changes.

  ## Examples

      iex> change_step(step)
      %Ecto.Changeset{data: %Step{}}

  """
  def change_step(%Step{} = step, attrs \\ %{}) do
    Step.changeset(step, attrs)
  end

  alias MTKitchen.Management.Ingredient

  @doc """
  Returns the list of ingredients.

  ## Examples

      iex> list_ingredients()
      [%Ingredient{}, ...]

  """
  def list_ingredients do
    Repo.all(Ingredient)
  end

  @doc """
  Gets a single ingredient.

  Raises `Ecto.NoResultsError` if the Ingredient does not exist.

  ## Examples

      iex> get_ingredient!(123)
      %Ingredient{}

      iex> get_ingredient!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ingredient!(id) do
    Repo.one!(
      from i in Ingredient,
        where: i.slug == ^id
    )
  end

  @doc """
  Creates a ingredient.

  ## Examples

      iex> create_ingredient(%{field: value})
      {:ok, %Ingredient{}}

      iex> create_ingredient(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ingredient(attrs \\ %{}) do
    %Ingredient{}
    |> Ingredient.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ingredient.

  ## Examples

      iex> update_ingredient(ingredient, %{field: new_value})
      {:ok, %Ingredient{}}

      iex> update_ingredient(ingredient, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ingredient(%Ingredient{} = ingredient, attrs) do
    original_url = ingredient.primary_picture

    result =
      ingredient
      |> Ingredient.changeset(attrs)
      |> Repo.update()

    case result do
      {:ok, ingredient_result} ->
        # Only delete image url if ingredient change was successful, and only do so if there was a change from some
        #   image url to something else
        if original_url && ingredient_result.primary_picture != original_url do
          Image.delete({original_url, ingredient_result})
        end

      {:err, changeset} ->
        changeset
    end

    result
  end

  @doc """
  Deletes a ingredient.

  ## Examples

      iex> delete_ingredient(ingredient)
      {:ok, %Ingredient{}}

      iex> delete_ingredient(ingredient)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ingredient(%Ingredient{} = ingredient) do
    original_url = ingredient.primary_picture

    result = Repo.delete(ingredient)

    case result do
      {:ok, ingredient_result} ->
        # Only delete image url if ingredient deletion was successful.
        # As the image has been deleted, we should always delete the image in this case.
        Image.delete({original_url, ingredient_result})

      {:err, changeset} ->
        changeset
    end

    result
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ingredient changes.

  ## Examples

      iex> change_ingredient(ingredient)
      %Ecto.Changeset{data: %Ingredient{}}

  """
  def change_ingredient(%Ingredient{} = ingredient, attrs \\ %{}) do
    Ingredient.changeset(ingredient, attrs)
  end

  alias MTKitchen.Management.StepIngredient

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking step_ingredient changes.

  ## Examples

      iex> change_step_ingredient(step_ingredient)
      %Ecto.Changeset{data: %StepIngredient{}}

  """
  def change_step_ingredient(%StepIngredient{} = step_ingredient, attrs \\ %{}) do
    StepIngredient.changeset(step_ingredient, attrs)
  end
end
