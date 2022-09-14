defmodule MTKitchen.Management do
  defdelegate authorize(action, user, params), to: MTKitchen.Management.Policy

  alias MTKitchen.Service.S3

  @moduledoc """
  The Management context.
  """

  import Ecto.Query, warn: false
  alias MTKitchen.Repo

  alias MTKitchen.Management.Recipe

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

  def get_full_public_recipe!(id, current_user_id \\ nil) do
    recipe =
      Repo.one!(
        from r in Recipe,
          where: r.slug == ^id,
          preload: [steps: [step_ingredients: [:ingredient]]]
      )

    if recipe.publicly_accessible do
      # Recipe is always visible if publicly accessible
      recipe
    else
      # If recipe is not publicly accessible, determine if user is still able to see recipe (owned recipe)
      if is_nil(current_user_id) or recipe.user_id != current_user_id do
        # * If not logged in, we do not know user, so they should not be able to see recipe
        # * If user is logged in but recipe is not owned by them (and not publicly accessible),
        #     they should not be able to see recipe
        raise MTKitchen.Error.ResourceNotFoundError
      else
        recipe
      end
    end
  end

  @doc """
  Creates a recipe.

  ## Examples

      iex> create_recipe(%{field: value})
      {:ok, %Recipe{}}

      iex> create_recipe(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_recipe(recipe, attrs \\ %{}, after_save \\ &{:ok, &1}) do
    recipe
    |> Recipe.information_changeset(attrs)
    |> Repo.insert()
    |> after_save(after_save)
  end

  @doc """
  Updates a recipe.

  ## Examples

      iex> update_recipe(recipe, %{field: new_value})
      {:ok, %Recipe{}}

      iex> update_recipe(recipe, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_recipe(%Recipe{} = recipe, attrs, after_save \\ &{:ok, &1}) do
    original_url = recipe.primary_picture

    result =
      recipe
      |> Recipe.information_changeset(attrs)
      |> Repo.update()
      |> after_save(after_save)

    case result do
      {:ok, recipe_result} ->
        # Only delete image url if recipe change was successful, and only do so if there was a change from some
        #   image url to something else
        if original_url && recipe_result.primary_picture != original_url do
          _ = S3.delete(recipe.primary_picture)
        end

      {:error, changeset} ->
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
      {:ok, _recipe_result} ->
        if original_url do
          # Only delete image url if recipe deletion was successful and only if the image url actually exists.
          # As the image has been deleted, we should always delete the image in this case.
          _ = S3.delete(recipe.primary_picture)
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
          _ = S3.delete(ingredient_result.primary_picture)
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
    _original_url = ingredient.primary_picture

    result = Repo.delete(ingredient)

    case result do
      {:ok, ingredient_result} ->
        # Only delete image url if ingredient deletion was successful.
        # As the image has been deleted, we should always delete the image in this case.
        _ = S3.delete(ingredient_result.primary_picture)

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

  @doc """
  Expose the default preview image for shared use
  """
  def default_preview_image, do: "assets/images/site/default_food.jpeg"

  @doc """
  Calculate a URL-safe random value to use as a temporary ID for managing nested resources with a LiveView.

  ## Examples

      iex> get_temp_id()
      "zIGRq"

  """
  def get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)

  # Execute some function action after a resource has been successfully saved
  defp after_save({:ok, resource}, func) do
    {:ok, _resource} = func.(resource)
  end

  # Pass-through the error after a resource was not successfully saved
  defp after_save(error, _func), do: error
end
