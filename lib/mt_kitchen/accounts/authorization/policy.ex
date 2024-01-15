defmodule MTKitchen.Accounts.Authorization.Policy do
  @behaviour Bodyguard.Policy

  alias MTKitchen.Accounts.User
  alias MTKitchen.Management.Recipe
  alias MTKitchen.Management.Step

  # Superusers can do anything
  def authorize(_action, %User{role: :superuser} = _user, _resource), do: :ok

  # Admins may edit their own user, but may not edit other admin or superuser users
  def authorize(_action, %User{id: current_user_id, role: :administrator}, %User{
        id: resource_user_id,
        role: :administrator
      }) do
    if current_user_id == resource_user_id do
      :ok
    else
      :error
    end
  end

  def authorize(_action, %User{id: current_user_id, role: :administrator}, %User{
        id: resource_user_id,
        role: :superuser
      }) do
    if current_user_id == resource_user_id do
      :ok
    else
      :error
    end
  end

  # Admins may edit any other resource that are not other admin or superuser users
  def authorize(_action, %User{role: :administrator}, _resource), do: true

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
      )
      when action in [
             :get_recipe!,
             :get_full_recipe!,
             :update_recipe,
             :update_recipe_steps,
             :delete_recipe
           ],
      do: true

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
      )
      when action in [
             :get_step!,
             :get_full_step!,
             :update_step_ingredients,
             :delete_step
           ],
      do: true

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
