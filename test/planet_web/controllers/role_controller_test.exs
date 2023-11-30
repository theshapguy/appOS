defmodule PlanetWeb.RoleControllerTest do
  use PlanetWeb.ConnCase, async: true

  import Planet.RolesFixtures
  import Planet.AccountsFixtures

  setup :register_and_log_in_user

  describe "GET /users/settings/roles/new" do
    test "renders page", %{conn: conn} do
      conn = get(conn, ~p"/users/settings/roles/new")
      response = html_response(conn, 200)
      assert response =~ "Create Role"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, ~p"/users/settings/roles/new")
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "GET /users/settings/roles/:id (Edit Role)" do
    setup :create_role

    test "renders page for specific role", %{conn: conn, role: role} do
      conn = get(conn, ~p"/users/settings/roles/#{role.id}/edit")
      response = html_response(conn, 200)
      assert response =~ role.name
      assert response =~ "Edit Role"
    end

    test "should fail to render page for role with different organization", %{
      conn: conn
    } do
      # Role With Different Organization
      role = role_fixture(user_fixture().organization)

      assert_raise Ecto.NoResultsError, fn ->
        get(conn, ~p"/users/settings/roles/#{role.id}/edit")
      end
    end
  end

  describe "create role" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn, ~p"/users/settings/roles", %{
          "role" => %{
            "name" => "Manager Role",
            "permissions" => ["billing-view"]
          }
        })

      assert redirected_to(conn) == ~p"/users/settings/team"

      conn = get(conn, ~p"/users/settings/team")
      response = html_response(conn, 200)
      assert response =~ "Manager Role"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/users/settings/roles", %{
          "role" => %{
            "name" => "Manager Role",
            "permissions" => ["undefined-permission"]
          }
        })

      assert html_response(conn, 200) =~ "Create Role"
    end
  end

  describe "PUT /users/settings/role/:id update role" do
    setup :create_role

    test "redirects to show when data is valid", %{conn: conn, role: role} do
      conn =
        put(conn, ~p"/users/settings/roles/#{role.id}", %{
          "role" => %{
            "name" => "Updated Role 123",
            "permissions" => ["billing-update"]
          }
        })

      assert redirected_to(conn) == ~p"/users/settings/team"

      conn = get(conn, ~p"/users/settings/team")
      response = html_response(conn, 200)
      assert response =~ "Updated Role 123"
    end

    test "renders errors when data is invalid", %{conn: conn, role: role} do
      conn =
        put(conn, ~p"/users/settings/roles/#{role.id}", %{
          "role" => %{
            "name" => "Updated Role 123",
            "permissions" => ["undefined"]
          }
        })

      assert html_response(conn, 200) =~ "Edit Role"
    end
  end

  describe "delete role" do
    setup [:create_role]

    test "deletes chosen role", %{conn: conn, role: role} do
      conn = delete(conn, ~p"/users/settings/roles/#{role.id}")
      assert redirected_to(conn) == ~p"/users/settings/team"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Role deleted successfully."

      assert_error_sent 404, fn ->
        get(conn, ~p"/users/settings/roles/#{role.id}/edit")
      end
    end

    test "cannot delete role if still associated with user", %{
      conn: conn,
      role: role,
      user: user
    } do
      user_role_fixture(user, role)

      conn = delete(conn, ~p"/users/settings/roles/#{role.id}")

      response = html_response(conn, 200)

      assert response =~ "Edit Role"
      assert response =~ "This role is still associated to an user."
    end
  end

  defp create_role(%{user: user}) do
    role = role_fixture(user.organization)
    %{role: role}
  end
end
