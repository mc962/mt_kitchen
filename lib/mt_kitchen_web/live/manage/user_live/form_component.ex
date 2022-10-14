defmodule MTKitchenWeb.Manage.UserLive.FormComponent do
  use MTKitchenWeb, :live_component

  alias MTKitchen.Accounts

  on_mount MTKitchenWeb.UserLiveAuth

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = Accounts.admin_change_user(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.admin_change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.admin_update_user(socket.assigns.user, user_params) do
      {:ok, user_result} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "User updated successfully.")
          |> push_redirect(to: Routes.manage_user_path(socket, :show, user_result.id))
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
