defmodule MTKitchenWeb.Manage.RecipeLive.FormComponent do
  use MTKitchenWeb, :live_component

  alias MTKitchen.Management
  alias MTKitchen.Management.Recipe

  alias MTKitchen.Management.Utility.Uploadable

  on_mount MTKitchenWeb.UserLiveAuth

  @impl true
  def mount(socket) do
    {:ok, allow_upload(socket, :primary_picture, accept: ~w(.jpg .jpeg .gif .png))}
  end

  @impl true
  def update(%{recipe: recipe} = assigns, socket) do
    changeset = Management.change_recipe(recipe)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"recipe" => recipe_params}, socket) do
    changeset =
      socket.assigns.recipe
      |> Management.change_recipe(recipe_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :primary_picture, ref)}
  end

  @impl true
  def handle_event("save", %{"recipe" => recipe_params}, socket) do
    save_recipe(socket, socket.assigns.action, recipe_params)
  end

  defp save_recipe(socket, :edit, recipe_params) do
    current_user = socket.assigns.current_user
    recipe = socket.assigns.recipe

    with :ok <- Bodyguard.permit!(Management, :update_recipe, current_user, recipe),
         {:ok, recipe} do
      primary_picture_url =
        Uploadable.extract_entry_key(socket, :primary_picture, "recipes", true)

      # Attach primary picture path to recipe params to insert into model
      recipe_params = Map.put(recipe_params, "primary_picture", primary_picture_url)

      case Management.update_recipe(
             recipe,
             recipe_params,
             &Uploadable.consume_attachments(
               socket,
               # Updated recipe
               &1,
               :primary_picture,
               "recipes"
             )
           ) do
        {:ok, recipe_result} ->
          {
            :noreply,
            socket
            |> put_flash(:info, "Recipe updated successfully.")
            |> push_redirect(to: Routes.manage_recipe_path(socket, :show, recipe_result.slug))
          }

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    end
  end

  defp save_recipe(socket, :new, params) do
    current_user = socket.assigns.current_user
    primary_picture_url = Uploadable.extract_entry_key(socket, :primary_picture, "recipes", true)
    # Attach primary picture path to recipe params to insert into model
    recipe_params = Map.put(params, "primary_picture", primary_picture_url)
    authenticated_recipe_params = authenticated_params(recipe_params, current_user)

    case Management.create_recipe(
           %Recipe{},
           authenticated_recipe_params,
           &Uploadable.consume_attachments(
             socket,
             # New recipe
             &1,
             :primary_picture,
             "recipes"
           )
         ) do
      {:ok, recipe} ->
        {:noreply,
         socket
         |> put_flash(:info, "Recipe created successfully.")
         |> push_redirect(to: Routes.manage_recipe_path(socket, :show, recipe.slug))}

      {:error, _recipe, %Ecto.Changeset{} = changeset, _current_changes} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  # Attach a Recipe to the current user
  defp authenticated_params(recipe_params, current_user) do
    Map.put(recipe_params, "user_id", current_user.id)
  end
end
