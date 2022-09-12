defmodule MTKitchenWeb.StepView do
  use MTKitchenWeb, :view

  alias MTKitchen.Management.Recipe
  alias MTKitchen.Management.Step

  def new_step(socket, recipe) do
    changeset = Recipe.recipe_steps_changeset(%Recipe{steps: [%Step{}]}, %{})
    form = Phoenix.HTML.FormData.to_form(changeset, [])
    render(__MODULE__, "_template_steps.html", socket: socket, recipe_form: form, recipe: recipe)
  end
end
