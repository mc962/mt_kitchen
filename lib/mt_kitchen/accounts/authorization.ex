defmodule MTKitchen.Accounts.Authorization do
  @moduledoc """
  The Accounts.Authorization context.
  """

  @allowed [
    {"Superuser", :superuser},
    {"Administrator", :administrator},
    # {"Moderator", :moderator},
    {"Editor", :editor}
  ]

  def allowed, do: @allowed
end
