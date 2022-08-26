defmodule MTKitchenWeb.StepIngredientView do
  use MTKitchenWeb, :view

  alias MTKitchen.Management.Step
  alias MTKitchen.Management.StepIngredient
  alias MTKitchen.Management.Ingredient

  def new_step_ingredient(conn, recipe, step) do
    changeset =
      Step.step_ingredients_changeset(
        %Step{
          id: step.id,
          recipe: recipe,
          step_ingredients: [%StepIngredient{ingredient: %Ingredient{}}]
        },
        %{}
      )

    form = Phoenix.HTML.FormData.to_form(changeset, [])
    render(__MODULE__, "_template_step_ingredients.html", conn: conn, step_form: form)
  end
end
