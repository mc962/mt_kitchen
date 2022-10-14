defmodule MTKitchenWeb.Manage.UserLive.Edit do
  use MTKitchenWeb, :live_view

  alias MTKitchen.Accounts.User

  on_mount MTKitchenWeb.UserLiveAuth

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:user, %User{})}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    user = MTKitchen.Accounts.get_full_user!(id)
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, user)
  end
end
