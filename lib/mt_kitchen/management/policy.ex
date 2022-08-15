defmodule MTKitchen.Management.Policy do
  @behaviour Bodyguard.Policy

  alias MTKitchen.Accounts.User
  alias MTKitchen.Management.Recipe
  alias MTKitchen.Management.Step

  # Admins can update anything
  def authorize(_, %User{role: :admin}, _), do: true

  # Regular users can create resources
  def authorize(:create_recipe, _, _), do: true
  def authorize(:create_step, _, _), do: true
  def authorize(:create_ingredient, _, _), do: true

  # Regular users can work with their own resources
  def authorize(action, %User{id: user_id}, %Recipe{user_id: user_id})
      when action in [:get_recipe!, :get_full_recipe!, :update_recipe, :update_recipe_steps, :delete_recipe], do: true

  def authorize(action, %User{id: user_id}, %Step{recipe: %Recipe{user_id: user_id}})
    when action in [:get_step!, :get_full_step!, :update_step_ingredients, :delete_step], do: true

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end