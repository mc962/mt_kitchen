defmodule MTKitchenWeb.UserSessionController do
  use MTKitchenWeb, :controller

  alias MTKitchen.Accounts
  alias MTKitchenWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      if Accounts.User.active_for_authentication?(user) do
        UserAuth.log_in_user(conn, user, user_params)
      else
        # TODO put in i18n
        render(conn, "new.html", error_message: "Your account has not been approved by your administrator yet.")
      end
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
