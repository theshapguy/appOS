defmodule PlanetWeb.UserSettingsOrganizationControllerTest do
  use PlanetWeb.ConnCase, async: true

  import Planet.RolesFixtures
  import Planet.AccountsFixtures

  setup :register_and_log_in_user

  describe "GET /users/settings/team" do
    test "renders settings page", %{conn: conn} do
      conn = get(conn, ~p"/users/settings/team")
      response = html_response(conn, 200)
      assert response =~ "Manage Your Team"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, ~p"/users/settings/team")
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "PUT /user/settings/team (change organization name form)" do
    @tag :capture_log
    test "updates the organization name", %{conn: conn} do
      conn =
        put(conn, ~p"/users/settings/team", %{
          "action" => "update_name",
          "organization" => %{"name" => "Valid Org Name"}
        })

      assert redirected_to(conn) == ~p"/users/settings/team"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Updated sucessfully"
    end

    test "does not update name on invalid data", %{conn: conn} do
      conn =
        put(conn, ~p"/users/settings/team", %{
          "action" => "update_name",
          "organization" => %{"name" => ""}
        })

      response = html_response(conn, 200)
      assert response =~ "can&#39;t be blank\n</p>"
      assert response =~ "Oops, something went wrong! Please check the errors below."
    end
  end

  describe "PUT /user/settings/team (update user role)" do
    # setup %{user: user} do
    #   %{user: user, another_admin_user: another_user_in_same_org_who_is_admin}
    # end

    @tag :capture_log
    test "updates the team member role for another user in same organization", %{
      conn: conn,
      user: user
    } do
      another_user_in_same_org =
        user_fixture(user.organization, role_fixture(user.organization))

      role = role_fixture(user.organization)

      conn =
        put(conn, ~p"/users/settings/team", %{
          "action" => "update_role",
          "role_id" => role.id,
          "user_id" => another_user_in_same_org.id
        })

      assert redirected_to(conn) ==
               ~p"/users/settings/team#manage-team-list-#{another_user_in_same_org.id}"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Role for [#{another_user_in_same_org.email}] updated sucessfully."
    end

    @tag :capture_log
    test "update the team member to admin", %{
      conn: conn,
      user: user
    } do
      role = role_fixture(user.organization)
      another_user = user_fixture(user.organization, role)

      [%Planet.Roles.Role{} = admin_role] = user.roles

      conn =
        put(conn, ~p"/users/settings/team", %{
          "action" => "update_role",
          "role_id" => admin_role.id,
          "user_id" => another_user.id
        })

      assert redirected_to(conn) ==
               ~p"/users/settings/team#manage-team-list-#{another_user.id}"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Role for [#{another_user.email}] updated sucessfully."

      assert Planet.Accounts.get_user!(another_user.id).organization_admin?
    end

    @tag :capture_log
    test "remove the team member from admin - if no other team admin fails", %{
      conn: conn,
      user: user
    } do
      role = role_fixture(user.organization)

      conn =
        put(conn, ~p"/users/settings/team", %{
          "action" => "update_role",
          "role_id" => role.id,
          "user_id" => user.id
        })

      assert redirected_to(conn) ==
               ~p"/users/settings/team#manage-team-list-#{user.id}"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Failed to update role for [#{user.email}]."

      assert Planet.Accounts.get_user!(user.id).organization_admin? == true
    end

    @tag :capture_log
    test "remove the team member from admin - if another admin exists in the team ", %{
      conn: conn,
      user: user
    } do
      [%Planet.Roles.Role{} = admin_role] = user.roles

      _another_user_in_same_org_who_is_admin =
        user_fixture(user.organization, admin_role)
        |> Planet.Accounts.update_user_organization_admin(%{
          "organization_admin?" => "true"
        })

      role = role_fixture(user.organization)

      conn =
        put(conn, ~p"/users/settings/team", %{
          "action" => "update_role",
          "role_id" => role.id,
          "user_id" => user.id
        })

      assert redirected_to(conn) ==
               ~p"/users/settings/team#manage-team-list-#{user.id}"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Role for [#{user.email}] updated sucessfully."

      assert Planet.Accounts.get_user!(user.id).organization_admin? == false
    end

    @tag :capture_log
    test "cannot access and update user from different organization", %{
      conn: conn,
      user: user
    } do
      user_another_org = user_fixture()
      role = role_fixture(user.organization)

      assert_raise Ecto.NoResultsError, fn ->
        conn
        |> put(~p"/users/settings/team", %{
          "action" => "update_role",
          "role_id" => role.id,
          "user_id" => user_another_org.id
        })
      end
    end

    @tag :capture_log
    test "cannot access and update role from different organization", %{
      conn: conn,
      user: user
    } do
      # Role From Another Organization
      role = role_fixture(user_fixture().organization)

      assert_raise Ecto.NoResultsError, fn ->
        conn
        |> put(~p"/users/settings/team", %{
          "action" => "update_role",
          "role_id" => role.id,
          "user_id" => user.id
        })
      end
    end
  end

  describe "PUT /user/settings/team (add organization member)" do
    @tag :capture_log

    setup %{user: user} do
      [admin_role, simple_role] = Planet.Roles.list_roles(user.organization)
      %{role: simple_role, admin_role: admin_role}
    end

    test "creates new user with current organization", %{conn: conn, role: role} do
      new_user_email = "new_user_email_44235323@email.com"

      conn =
        put(
          conn,
          ~p"/users/settings/team",
          %{
            "action" => "add_organization_member",
            "user" => %{"email" => new_user_email},
            "role_id" => role.id
          }
        )

      assert redirected_to(conn) == ~p"/users/settings/team"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Invited sucessfully."
    end

    test "invite already existing user to current organization", %{conn: conn, role: role} do
      new_user_email = "new_user_email_1110000@email.com"

      conn =
        put(
          conn,
          ~p"/users/settings/team",
          %{
            "action" => "add_organization_member",
            "user" => %{"email" => new_user_email},
            "role_id" => role.id
          }
        )

      assert redirected_to(conn) == ~p"/users/settings/team"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Invited sucessfully."

      # User Already Created Above
      conn =
        put(
          conn,
          ~p"/users/settings/team",
          %{
            "action" => "add_organization_member",
            "user" => %{"email" => new_user_email},
            "role_id" => role.id
          }
        )

      response = html_response(conn, 200)
      assert response =~ "has already been taken\n</p>"
      assert response =~ "Oops, something went wrong! Please check the errors below."

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Failed to invite user into your team."
    end

    test "does not creates user with current organization with invalid data", %{
      conn: conn,
      role: role
    } do
      new_user_email_invalid = "new_user_email_44235323"

      conn =
        put(
          conn,
          ~p"/users/settings/team",
          %{
            "action" => "add_organization_member",
            "user" => %{"email" => new_user_email_invalid},
            "role_id" => role.id
          }
        )

      assert html_response(conn, 200) =~ "must have the @ sign and no spaces"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Failed to invite user into your team."
    end

    test "does not creates user with current organization with role from another organization", %{
      conn: conn
    } do
      another_organization = organization_fixture()
      role_another_organization = role_fixture(another_organization)

      assert_raise Ecto.NoResultsError, fn ->
        put(
          conn,
          ~p"/users/settings/team",
          %{
            "action" => "add_organization_member",
            "user" => %{"email" => "email213@email.com"},
            "role_id" => role_another_organization.id
          }
        )
      end
    end
  end

  describe "GET /users/settings/team/" do
    test "renders roles for current organization", %{conn: conn, user: user} do
      role_fixture(
        user.organization,
        %{name: "###Role Fixtures###"}
      )

      # Role From Different Organization (Should Not Render)
      role_fixture(
        user_fixture().organization,
        %{name: "###Role Unrendered###"}
      )

      conn =
        conn
        |> get(~p"/users/settings/team")

      response = html_response(conn, 200)
      assert response =~ "Roles & Permissions"
      assert response =~ "Add New Role"
      assert response =~ "###Role Fixtures###"
      refute response =~ "###Role Unrendered###"
    end
  end
end
