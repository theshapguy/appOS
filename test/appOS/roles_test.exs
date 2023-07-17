defmodule AppOS.RolesTest do
  use AppOS.DataCase

  alias AppOS.Roles
  import AppOS.AccountsFixtures

  describe "roles" do
    alias AppOS.Roles.Role

    import AppOS.RolesFixtures

    @invalid_attrs %{
      active: nil,
      name: nil,
      permissions: ["non-existing-permission", "non-existing-permission-2"]
    }

    setup do
      user = user_fixture()
      role = role_fixture(user.organization, %{})

      %{user: user, role: role}
    end

    test "list_roles/0 returns all roles", %{user: user, role: role} do
      roles = Roles.list_roles(user.organization)

      %Role{id: role_id} = Enum.find(roles, fn item -> item.id == role.id end)

      assert role_id == role.id
      assert length(Roles.list_roles(user.organization)) == 3
    end

    test "get_role!/1 returns the role with given id", %{user: user, role: role} do
      %Role{id: id} = Roles.get_role!(user.organization, role.id)
      assert id == role.id
    end

    test "get_role!/1 raises error when role id and organiaztion id does not match",
         %{user: user} do
      role2 = role_fixture(user_fixture().organization)

      assert_raise Ecto.NoResultsError, fn ->
        assert Roles.get_role!(user.organization, role2.id).id == role2.id
      end
    end

    test "create_role/1 with valid data creates a role", %{user: user} do
      valid_attrs = %{
        active: true,
        name: "some name",
        permissions: ["billing-view", "billing-update"]
      }

      assert {:ok, %Role{} = role} = Roles.create_role(user.organization, valid_attrs)
      assert role.active == true
      assert role.name == "some name"
      # Ordered Alphabetically
      assert role.permissions == ["billing-update", "billing-view"]
    end

    test "create_role/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Roles.create_role(user.organization, @invalid_attrs)
    end

    test "update_role/2 with valid data updates the role", %{user: user, role: role} do
      update_attrs = %{
        active: false,
        name: "some updated name",
        permissions: ["billing-view"]
      }

      assert {:ok, %Role{} = role} = Roles.update_role(user.organization, role, update_attrs)
      assert role.active == false
      assert role.name == "some updated name"
      assert role.permissions == ["billing-view"]
    end

    test "update_role/2 with invalid data returns error changeset", %{user: user, role: role} do
      %Role{id: role_id_0} = role

      assert {:error, %Ecto.Changeset{}} =
               Roles.update_role(user.organization, role, @invalid_attrs)

      %Role{id: role_id_1} = Roles.get_role!(user.organization, role.id)

      assert role_id_0 == role_id_1
    end

    test "delete_role/1 deletes the role", %{user: user, role: role} do
      assert {:ok, %Role{}} = Roles.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> Roles.get_role!(user.organization, role.id) end
    end

    test "change_role/1 returns a role changeset", %{role: role} do
      assert %Ecto.Changeset{} = Roles.change_role(role)
    end

    test "change_role_registration/1 returns a role changeset", %{role: role} do
      assert %Ecto.Changeset{} = Roles.change_role_registration(role)
    end
  end
end
