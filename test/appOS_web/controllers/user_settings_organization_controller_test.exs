defmodule AppOSWeb.UserSettingsOrganizationControllerTest do
  use AppOSWeb.ConnCase, async: true

  # alias AppOS.Accounts
  # import AppOS.AccountsFixtures

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

  describe "PUT /user/settings/team (add organization member)" do
    @tag :capture_log

    test "creates new user with current organization", %{conn: conn} do
      new_user_email = "new_user_email_44235323@email.com"

      conn =
        put(
          conn,
          ~p"/users/settings/team",
          %{
            "action" => "add_organization_member",
            "user" => %{"email" => new_user_email}
          }
        )

      assert redirected_to(conn) == ~p"/users/settings/team"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Invited sucessfully."
    end

    test "invite already existing user to current organization", %{conn: conn} do
      new_user_email = "new_user_email_1110000@email.com"

      conn =
        put(
          conn,
          ~p"/users/settings/team",
          %{
            "action" => "add_organization_member",
            "user" => %{"email" => new_user_email}
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
            "user" => %{"email" => new_user_email}
          }
        )

      response = html_response(conn, 200)
      assert response =~ "has already been taken\n</p>"
      assert response =~ "Oops, something went wrong! Please check the errors below."

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Failed to invite user into your team."
    end

    test "does not creates user with current organization with invalid data", %{conn: conn} do
      new_user_email_invalid = "new_user_email_44235323"

      conn =
        put(
          conn,
          ~p"/users/settings/team",
          %{
            "action" => "add_organization_member",
            "user" => %{"email" => new_user_email_invalid}
          }
        )

      assert html_response(conn, 200) =~ "must have the @ sign and no spaces"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Failed to invite user into your team."
    end
  end
end
