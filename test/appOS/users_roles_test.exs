defmodule AppOS.UsersRolesTest do
  use AppOS.DataCase

  import AppOS.AccountsFixtures
  import AppOS.RolesFixtures

  alias AppOS.Accounts.User
  # alias AppOS.UsersRoles
  # alias AppOS.Organizations.Organization

  describe "update user roles" do
    setup do
      user = user_fixture()

      %{
        user: user,
        role: role_fixture(user.organization),
        admin_role: Enum.at(user.roles, 0)
      }
    end

    test "add role to user", %{user: user, admin_role: admin_role, role: role} do
      {:ok, %User{} = user} =
        AppOS.UsersRoles.update_user_roles(user, [admin_role, role])

      assert user.roles == [admin_role, role]
      assert user.organization_admin?
    end

    test "remove role from user", %{user: user, admin_role: admin_role} do
      {:ok, _u} =
        AppOS.Accounts.update_user_organization_admin(user, %{"organization_admin?" => "false"})

      {:ok, %User{} = user} =
        AppOS.UsersRoles.update_user_roles(user, [admin_role])

      assert user.roles == [admin_role]
      assert user.organization_admin?
    end

    test "remove admin role if only another user in the same organization has admin permission",
         %{
           user: user,
           role: role
         } do
      _another_user_in_same_org_who_is_admin =
        user_fixture(user.organization, role_fixture(user.organization))
        |> AppOS.Accounts.update_user_organization_admin(%{
          "organization_admin?" => "true"
        })

      {:ok, %User{} = user_updated} =
        AppOS.UsersRoles.update_user_roles(user, [role])

      assert user_updated.roles == [role]
      assert user_updated.organization_admin? == false
    end
  end
end
