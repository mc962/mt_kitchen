defmodule MTKitchen.Management.Policy do
  @behaviour Bodyguard.Policy

  alias MTKitchen.Accounts.User
  alias MTKitchen.Accounts.Role
  alias MTKitchen.Management.Recipe
  alias MTKitchen.Management.Step

  # Regular users can create resources
  def authorize(:create_recipe, _, _), do: true
  def authorize(:create_step, _, _), do: true
  def authorize(:create_ingredient, _, _), do: true

  # Regular users can work with their own resources
  # Recipe may be updated if it belongs to current User
  def authorize(
        action,
        %User{
          id: user_id
        },
        %Recipe{
          user_id: user_id
        }
      ) when action in [
    :get_recipe!,
    :get_full_recipe!,
    :update_recipe,
    :update_recipe_steps,
    :delete_recipe
  ], do: true

  # Step may be updated if it belongs to Recipe that belongs to current User
  def authorize(
        action,
        %User{
          id: user_id
        },
        %Step{
          recipe: %Recipe{
            user_id: user_id
          }
        }
      ) when action in [
    :get_step!,
    :get_full_step!,
    :update_step_ingredients,
    :delete_step
  ], do: true

  # Admins can update anything
  def authorize(_, %User{id: user_id} = user, _opts) do
    MTKitchen.Accounts.Utility.Rolify.has_role?(
      user,
      "admin"
    )
  end

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end