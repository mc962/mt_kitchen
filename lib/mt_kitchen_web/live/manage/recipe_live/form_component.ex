defmodule MTKitchenWeb.Manage.RecipeLive.FormComponent do
  use MTKitchenWeb, :live_component

  alias MTKitchen.Management
  alias MTKitchen.Management.Recipe

  on_mount MTKitchenWeb.UserLiveAuth

  @impl true
  def mount(socket) do
    {:ok, allow_upload(socket, :primary_picture, accept: ~w(.jpg .jpeg .gif .png))}
#    {:ok,
#      socket
#      |> assign(:uploaded_files, [])
#      |> allow_upload(:primary_picture, accept: ~w(.jpg .jpeg .gif .png), max_entries: 1)}
  end

  @impl true
  def update(%{recipe: recipe} = assigns, socket) do
    changeset = Management.change_recipe(recipe)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
#     |> allow_upload(:primary_picture, accept: ~w(.jpg .jpeg .gif .png), max_entries: 1)}
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

      recipe = put_primary_picture_urls(socket, socket.assigns.recipe)
      IO.inspect(recipe)
      # Attach primary picture path to recipe params to insert into model
      case Management.update_recipe(recipe, recipe_params) do
        {:ok, _recipe} ->
          {
            :noreply,
            socket
            |> put_flash(:info, "Recipe updated successfully.")
#            |> update(socket, :uploaded_files, &(&1 ++ uploaded_files))
            |> push_redirect(to: Routes.manage_recipe_path(socket, :show, recipe.slug))
          }

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    end
  end

  defp save_recipe(socket, :new, params) do
    current_user = socket.assigns.current_user
    authenticated_recipe_params = authenticated_params(params, current_user)

    recipe = put_primary_picture_urls(socket, %Recipe{})

    case Management.create_recipe(recipe, authenticated_recipe_params) do
      {:ok, recipe} ->
        {:noreply,
         socket
         |> put_flash(:info, "Recipe created successfully.")
         |> push_redirect(to: Routes.manage_recipe_path(socket, :show, recipe.slug))}

      {:error, _recipe, %Ecto.Changeset{} = changeset, _current_changes} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp put_primary_picture_urls(socket, %Recipe{} = recipe) do
    {completed, []} = uploaded_entries(socket, :primary_picture)

    urls = for entry <- completed do
            Routes.static_path(socket, "/images/uploads/#{entry.uuid}.#{ext(entry)}")
          end

    %Recipe{recipe | primary_picture: List.first(urls)}
  end

  defp ext(entry) do
    # Get first valid extension
    [extension | _] = MIME.extensions(entry.client_type)
    extension
  end

  defp authenticated_params(recipe_params, current_user) do
    Map.put(recipe_params, "user_id", current_user.id)
  end
end
