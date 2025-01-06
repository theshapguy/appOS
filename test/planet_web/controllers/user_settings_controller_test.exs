defmodule PlanetWeb.UserSettingsControllerTest do
  use PlanetWeb.ConnCase, async: true
  use Mimic

  alias Planet.Accounts
  import Planet.AccountsFixtures

  setup :register_and_log_in_user

  @tz_cookie_key Application.compile_env(:planet, PlanetWeb.Endpoint)
                 |> Keyword.fetch!(:tz_cookie_key)

  setup %{conn: conn} do
    %{
      conn: conn |> put_req_cookie(@tz_cookie_key, "Etc/UTC")
    }
  end

  describe "GET /users/settings" do
    test "renders settings page", %{conn: conn} do
      # conn =
      #   conn
      #   |> get(~p"/users/settings")

      # response = html_response(conn, 200)
      # assert response =~ "Settings"

      conn = get(conn, ~p"/users/settings")
      response = html_response(conn, 200)
      assert response =~ "Settings"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, ~p"/users/settings")
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "PUT /users/settings (change password form)" do
    test "updates the user password and resets tokens", %{conn: conn, user: user} do
      new_password_conn =
        put(conn, ~p"/users/settings", %{
          "action" => "update_password",
          "current_password" => valid_user_password(),
          "user" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(new_password_conn) == ~p"/users/settings"

      assert get_session(new_password_conn, :user_token) != get_session(conn, :user_token)

      assert Phoenix.Flash.get(new_password_conn.assigns.flash, :info) =~
               "Password updated successfully"

      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "does not update password on invalid data", %{conn: conn} do
      old_password_conn =
        put(conn, ~p"/users/settings", %{
          "action" => "update_password",
          "current_password" => "invalid",
          "user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(old_password_conn, 200)
      assert response =~ "Settings"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
      assert response =~ "is not valid"

      assert get_session(old_password_conn, :user_token) == get_session(conn, :user_token)
    end
  end

  describe "PUT /users/settings (change email form)" do
    @tag :capture_log
    test "updates the user email", %{conn: conn, user: user} do
      conn =
        put(conn, ~p"/users/settings", %{
          "action" => "update_email",
          "current_password" => valid_user_password(),
          "user" => %{"email" => unique_user_email()}
        })

      assert redirected_to(conn) == ~p"/users/settings"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "A link to confirm your email"

      assert Accounts.get_user_by_email(user.email)
    end

    test "does not update email on invalid data", %{conn: conn} do
      conn =
        put(conn, ~p"/users/settings", %{
          "action" => "update_email",
          "current_password" => "invalid",
          "user" => %{"email" => "with spaces"}
        })

      response = html_response(conn, 200)
      assert response =~ "Settings"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "is not valid"
    end
  end

  describe "PUT /users/settings (change name form)" do
    @tag :capture_log
    test "updates the user email", %{conn: conn} do
      conn =
        put(conn, ~p"/users/settings", %{
          "action" => "update_name",
          "user" => %{"name" => unique_user_email()}
        })

      assert redirected_to(conn) == ~p"/users/settings/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Name updated successfully"
    end

    test "does not update name on invalid data", %{conn: conn} do
      conn =
        put(conn, ~p"/users/settings", %{
          "action" => "update_name",
          "user" => %{"name" => String.duplicate(unique_user_email(), 100)}
        })

      response = html_response(conn, 200)
      assert response =~ "Settings"
      assert response =~ "Oops, something went wrong! Please check the errors below"
      assert response =~ " should be at most 255 character(s)"
    end

    test "does not update name on same data", %{conn: conn, user: user} do
      conn =
        put(conn, ~p"/users/settings", %{
          "action" => "update_name",
          "user" => %{"name" => user.name}
        })

      response = html_response(conn, 200)
      assert response =~ "Settings"
      assert response =~ "Oops, something went wrong! Please check the errors below"
      assert response =~ "did not change"
    end
  end

  describe "PUT /users/settings (change timezone form)" do
    @tag :capture_log
    test "updates the user timezone", %{conn: conn} do
      conn =
        put(conn, ~p"/users/settings", %{
          "action" => "update_timezone",
          "user" => %{"timezone" => "Asia/Kathmandu"}
        })

      assert redirected_to(conn) == ~p"/users/settings/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Timezone updated successfully"
    end

    test "does not update name on invalid data", %{conn: conn} do
      conn =
        put(conn, ~p"/users/settings", %{
          "action" => "update_timezone",
          "user" => %{"timezone" => "Apple/Ball"}
        })

      response = html_response(conn, 200)
      assert response =~ "Settings"
      assert response =~ "Oops, something went wrong! Please check the errors below"
      assert response =~ " timezone does not exist"
    end

    test "does not update name on same data", %{conn: conn} do
      conn =
        put(conn, ~p"/users/settings", %{
          "action" => "update_timezone",
          "user" => %{"timezone" => "Etc/UTC"}
        })

      response = html_response(conn, 200)
      assert response =~ "Settings"
      assert response =~ "Oops, something went wrong! Please check the errors below"
      assert response =~ "did not change"
    end
  end

  describe "GET /users/settings/confirm_email/:token" do
    setup %{user: user} do
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{token: token, email: email}
    end

    test "updates the user email once", %{conn: conn, user: user, token: token, email: email} do
      conn = get(conn, ~p"/users/settings/confirm_email/#{token}")
      assert redirected_to(conn) == ~p"/users/settings"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Email changed successfully"

      refute Accounts.get_user_by_email(user.email)
      assert Accounts.get_user_by_email(email)

      conn = get(conn, ~p"/users/settings/confirm_email/#{token}")

      assert redirected_to(conn) == ~p"/users/settings"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Email change link is invalid or it has expired"
    end

    test "does not update email with invalid token", %{conn: conn, user: user} do
      conn = get(conn, ~p"/users/settings/confirm_email/oops")
      assert redirected_to(conn) == ~p"/users/settings"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Email change link is invalid or it has expired"

      assert Accounts.get_user_by_email(user.email)
    end

    test "redirects if user is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, ~p"/users/settings/confirm_email/#{token}")
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  # describe "PUT /users/settings: WebAuthN Add Passkey" do
  # test "creates credential", %{conn: conn} do
  #   # Mocking So That Can Test Passkeys
  #   Wax
  #   |> stub(:register, fn _x, _y, _z -> :stub end)
  #   |> expect(:register, fn _x, _y, _z -> {:ok, {wax_authentication_data_fixture(), -1}} end)

  #   conn =
  #     conn
  #     |> put(~p"/users/settings", %{
  #       "action" => "add_credential_key",
  #       "webauthn" => %{
  #         "attestationObject" => "VGVzdERhdGE=",
  #         "clientDataJSON" => "client_data_json",
  #         "rawID" => "raw_id_b64",
  #         "type" => "public-key",
  #         "deviceName" => "Test Device [Phoenix]"
  #       }
  #     })

  #   assert redirected_to(conn) == ~p"/users/settings"

  #   assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
  #            "Passkey added successfully"

  #   conn = get(conn, ~p"/users/settings")
  #   response = html_response(conn, 200)

  #   assert response =~ "Test Device [Phoenix]"
  # end

  # test "fails to credential on wax error", %{conn: conn} do
  #   # Mocking So That Can Test Passkeys
  #   Wax
  #   |> stub(:register, fn _x, _y, _z -> :stub end)
  #   |> expect(:register, fn _x, _y, _z -> {:error, :error} end)

  #   conn =
  #     conn
  #     |> put(~p"/users/settings", %{
  #       "action" => "add_credential_key",
  #       "webauthn" => %{
  #         "attestationObject" => "VGVzdERhdGE=",
  #         "clientDataJSON" => "client_data_json",
  #         "rawID" => "raw_id_b64",
  #         "type" => "public-key",
  #         "deviceName" => "Test Device [Phoenix]"
  #       }
  #     })

  #   assert redirected_to(conn) == ~p"/users/settings"

  #   assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
  #            "Failed to add passkey."
  # end

  #   test "fails to credential on changeset", %{conn: conn, user: user} do
  #     user_credential = user_credential_fixture(user)

  #     # Mocking So That Can Test Passkeys
  #     Wax
  #     |> stub(:register, fn _x, _y, _z -> :stub end)
  #     |> expect(:register, fn _x, _y, _z -> {:ok, {wax_authentication_data_fixture(), -1}} end)

  #     conn =
  #       conn
  #       |> put(~p"/users/settings", %{
  #         "action" => "add_credential_key",
  #         "webauthn" => %{
  #           "attestationObject" => "VGVzdERhdGE=",
  #           "clientDataJSON" => "client_data_json",
  #           "rawID" => user_credential.credential_id,
  #           "type" => "public-key",
  #           "deviceName" => "Test Device [Phoenix]"
  #         }
  #       })

  #     assert redirected_to(conn) == ~p"/users/settings"

  #     assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
  #              "Failed to add passkey."
  #   end
  # end

  # describe "DELETE /users/settings: WebAuthN Delete Passkey" do
  #   test "delete credential", %{conn: conn, user: user} do
  #     user_credential = user_credential_fixture(user)

  #     conn =
  #       delete(conn, ~p"/users/settings/credentials/#{user_credential.id}")

  #     assert redirected_to(conn) == ~p"/users/settings"

  #     assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
  #              "Passkey sucessfully removed."

  #     conn = get(conn, ~p"/users/settings")
  #     response = html_response(conn, 200)

  #     refute response == user_credential.nickname
  #   end
  # end
end
