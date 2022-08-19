defmodule MTKitchenWeb.UserLiveAuth do
  import Phoenix.LiveView

  alias MTKitchen.Accounts

#  on_mount MTKitchenWeb.UserLiveAuth

  def on_mount(:default, _params, %{"user_token" => user_token} = _session, socket) do
    socket = assign_new(socket, :current_user, fn ->
      Accounts.get_user_by_session_token(user_token)
    end)

    if socket.assigns.current_user && socket.assigns.current_user.confirmed_at do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/users/log_in")}
    end
  end

  def on_mount(:default, _params, _session, socket) do
    {:halt, redirect(socket, to: "/users/log_in")}
  end
end