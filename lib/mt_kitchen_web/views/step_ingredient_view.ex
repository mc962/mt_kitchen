defmodule MTKitchenWeb.StepIngredientView do
  use MTKitchenWeb, :view

  alias MTKitchen.Management.Step
  alias MTKitchen.Management.StepIngredient
  alias MTKitchen.Management.Ingredient

  def new_step_ingredient(conn, recipe, step) do
    current_user = conn.assigns.current_user

    changeset = Step.step_ingredients_changeset(
      %Step{id: step.id, recipe: recipe, step_ingredients: [%StepIngredient{ingredient: %Ingredient{user_id: current_user.public_id}}]},
      %{}
    )
    form = Phoenix.HTML.FormData.to_form(changeset, [])
    render(__MODULE__, "_template_step_ingredients.html", conn: conn, step_form: form)
  end
end
