# select distinct users.role

# for role in distinct role -> create Role
# for role in user.role, create user_role w

defmodule  MTKitchen.Repo.Migrations.Scripts.ComplexRoles do
  import Ecto.Query, warn: false
  alias MTKitchen.Repo

  alias MTKitchen.Accounts.User
  alias MTKitchen.Accounts.Authorization


  def up do
    distinct_role_users = from(u in User, distinct: true, select: %{id: u.id, role: u.role}) |> Repo.all()

    for role_user <- distinct_role_users do
      role = Authorization.create_role(%{name: role_user})

      Authorization.promote_user(
        %{
          role: %{
            name: role_user.role,
            user_roles: %{
              user_id: role_user.id
            }
          }
        }
      )
    end
  end

  def down do

  end
end