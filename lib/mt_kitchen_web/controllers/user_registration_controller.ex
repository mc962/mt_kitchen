defmodule MTKitchenWeb.UserRegistrationController do
  use MTKitchenWeb, :controller

  alias MTKitchen.Accounts
  alias MTKitchen.Accounts.User

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        # Deliver instructions to user for confirming their account.
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :edit, &1)
          )

        # Deliver instructions to admins so that they may approve the account for logging in.
        Accounts.new_user_waiting_for_approval()

        conn
        |> put_flash(
          :info,
          "You have signed up successfully but your account has not been approved by your administrator yet."
        )
        |> redirect(to: Routes.root_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
