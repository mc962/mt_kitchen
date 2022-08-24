defmodule MTKitchen.Accounts.Utility.Rolify do
  @moduledoc """
  Provides an API and convenience methods for role-based Authorization based on
  Ruby's [rolify](https://github.com/RolifyCommunity/rolify). For simplicity, only certain methods for only global
  roles have been implemented at this time.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias MTKitchen.Repo

  alias MTKitchen.Accounts.Role
  alias MTKitchen.Accounts.User
  alias MTKitchen.Accounts.UserRole

  def add_role(%User{} = user, name) do
    Multi.new()
    |> Multi.insert(:role, Role.changeset(%Role{}, %{name: name}), on_conflict: [set: [name: name]], conflict_target: :name)
    |> Multi.run(:user_role, fn (repo, %{role: role}) ->
      repo.insert(UserRole.changeset(%UserRole{}, %{user_id: user.id, role_id: role.id}))
    end)
    |> Repo.transaction()
  end
  defdelegate grant(user, name), to: MTKitchen.Accounts.Utility.Rolify, as: :add_role

  def has_role?(user, name) do
    query = from r in Role,
                 join: ur in UserRole, on: ur.role_id == r.id,
                 join: u in User, on: ur.user_id == u.id,
                 where: ur.user_id == ^user.id
                  and r.name == ^name

    Repo.exists?(query)
  end

  def has_any_role?(user, names) do
    query = from r in Role,
                 join: ur in UserRole, on: ur.role_id == r.id,
                 join: u in User, on: ur.user_id == u.id,
                 where: ur.user_id == ^user.id
                  and r.name in ^names

    Repo.exists?(query)
  end

  def has_all_roles?(user, names) do
    user_roles = roles(user)
                  |> Enum.map(fn role -> role.name end)
                  |> MapSet.new()

    expected_roles = MapSet.new(names)

    MapSet.subset?(expected_roles, user_roles)
  end

  def roles(user) do
    query = from r in Role,
                 join: ur in UserRole, on: ur.role_id == r.id,
                 join: u in User, on: ur.user_id == u.id,
                 where: ur.user_id == ^user.id

    Repo.all(query)
  end

  def with_role(name) do
    query = from u in User,
                join: ur in UserRole, on: ur.user_id == u.id,
                join: r in Role, on: ur.role_id == r.id,
                where: r.name == ^name

    Repo.all(query)
  end

#  def without_role(name) do
#    query = from u in User,
#                 join: ur in UserRole, on: ur.user_id == u.id,
#                 join: r in Role, on: ur.role_id == r.id,
#                 where: r.name != ^name
#
#    Repo.all(query)
#  end

  def remove_role(user, name) do
    query = from ur in UserRole,
              join: r in Role, on: ur.role_id == r.id,
              where: r.name == ^name
                and ur.user_id == ^user.id

    Repo.delete_all(query)
  end
  defdelegate revoke(user, name), to: MTKitchen.Accounts.Utility.Rolify, as: :remove_role
end