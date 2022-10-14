defmodule MTKitchen.Accounts.AuthorizationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MTKitchen.Accounts.Authorization` context.
  """

  @doc """
  Generate a role.
  """
  def role_fixture(attrs \\ %{}) do
    {:ok, role} =
      attrs
      |> Enum.into(%{})
      |> MTKitchen.Accounts.Authorization.create_role()

    role
  end
end
