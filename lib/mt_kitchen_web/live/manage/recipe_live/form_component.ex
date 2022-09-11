defmodule MTKitchenWeb.Manage.RecipeLive.FormComponent do
  use MTKitchenWeb, :live_component

  alias MTKitchen.Management
  alias MTKitchen.Management.Recipe

  alias MTKitchenWeb.S3

  on_mount MTKitchenWeb.UserLiveAuth

  @impl true
  def mount(socket) do
    {:ok,
     allow_upload(socket, :primary_picture,
       accept: ~w(.jpg .jpeg .gif .png),
       external: &presign_entry/2
     )}

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
    IO.puts("EDIT")

    current_user = socket.assigns.current_user
    recipe = socket.assigns.recipe

    with :ok <- Bodyguard.permit!(Management, :update_recipe, current_user, recipe),
         {:ok, recipe} do
      IO.inspect(recipe)
      recipe = put_primary_picture_urls(socket, socket.assigns.recipe)
      # Attach primary picture path to recipe params to insert into model
      case Management.update_recipe(
             recipe,
             recipe_params,
             &consume_attachments(
               socket,
               # Updated recipe
               &1
             )
           ) do
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
    IO.puts("NEW")
    current_user = socket.assigns.current_user
    authenticated_recipe_params = authenticated_params(params, current_user)

    recipe = put_primary_picture_urls(socket, %Recipe{})

    case Management.create_recipe(
           recipe,
           authenticated_recipe_params,
           &consume_attachments(
             socket,
             # New recipe
             &1
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

  defp put_primary_picture_urls(socket, %Recipe{} = recipe) do
    {completed, []} = uploaded_entries(socket, :primary_picture)

    urls =
      for entry <- completed do
        #            Routes.static_path(socket, "/images/uploads/#{S3.key(entry)}")
        Path.join(S3.host(), S3.key(entry))
      end

      IO.inspect(urls, "ALL URLS")
      IO.inspect(List.first(urls), "PRIMARY URLS")
    %Recipe{recipe | primary_picture: List.first(urls)}
  end

  defp authenticated_params(recipe_params, current_user) do
    Map.put(recipe_params, "user_id", current_user.id)
  end

  defp consume_attachments(socket, %Recipe{} = recipe) do
    consume_uploaded_entries(socket, :primary_picture, fn _meta, _entry ->
      :ok

      #      dest = Path.join([:code.priv_dir(:mt_kitchen), "static", "images", "uploads", S3.key(entry)])

      #      dest = Path.join("priv/static/uploads", "#{entry.uuid}.#{ext(entry)}")
      #      IO.inspect(meta.path, label: "THE PATH")
      #      File.cp!(meta.path, dest) # TODO send this to S3 in this step instead
      #      {:ok, Routes.static_path(socket, "/images/uploads/#{S3.key(entry)}")}
    end)

    {:ok, recipe}
  end

  defp presign_entry(entry, socket) do
    uploads = socket.assigns.uploads
    key = S3.key(entry)

    config = %{
      scheme: Application.get_env(:ex_aws, :s3)[:scheme],
      host: Application.get_env(:ex_aws, :s3)[:host],
      region: Application.get_env(:ex_aws, :s3)[:region],
      access_key_id: Application.get_env(:ex_aws, :s3)[:access_key_id],
      secret_access_key: Application.get_env(:ex_aws, :s3)[:secret_access_key],
    }

    {:ok, fields} =
      S3.sign_form_upload(
        config,
        Application.get_env(:ex_aws, :s3)[:bucket],
        key: key,
        content_type: entry.client_type,
        max_file_size: uploads.primary_picture.max_file_size,
        expires_in: :timer.hours(1)
      )

    meta = %{uploader: "S3", key: key, url: S3.host(), fields: fields}
    {:ok, meta, socket}
  end
end
