defmodule PlanetWeb.UserSessionControllerTest do
  use PlanetWeb.ConnCase, async: true

  import Planet.AccountsFixtures
  use Mimic

  setup do
    %{user: user_fixture()}
  end

  describe "GET /users/log_in" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, ~p"/users/log_in")
      response = html_response(conn, 200)
      assert response =~ "Log in"
      assert response =~ ~p"/users/register"
      assert response =~ "Forgot your password?"
    end

    test "redirects if already logged in", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> get(~p"/users/log_in")
      assert redirected_to(conn) == ~p"/app"
    end
  end

  describe "POST /users/log_in" do
    test "logs the user in", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == ~p"/app"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/app")
      response = html_response(conn, 200)
      assert response =~ user.email
      assert response =~ ~p"/users/settings"
      assert response =~ ~p"/users/log_out"
    end

    test "logs the user in with remember me", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_app_os_web_user_remember_me"]
      assert redirected_to(conn) == ~p"/app"
    end

    test "logs the user in with return to", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_return_to: "/foo/bar")
        |> post(~p"/users/log_in", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "emits error message with invalid credentials", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => user.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "Log in"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /users/log_out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(~p"/users/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/users/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end

  describe "POST /users/log_in WebAuthn (Passkeys)" do
    setup do
      # TODO
      webauthn_user = user_fixture()
      credential = user_credential_fixture(webauthn_user)
      %{user: webauthn_user, credential: credential}
    end

    test "logs the user in", %{conn: conn, user: user, credential: _credential} do
      # Mocking So That Can Test Passkeys
      Wax
      |> stub(:authenticate, fn _u, _v, _w, _x, _y, _z -> :stub end)
      |> expect(:authenticate, fn _u, _v, _w, _x, _y, _z -> {:ok, :ok} end)

      conn =
        conn
        # |> put_session(:authentication_challenge, Wax.new_authentication_challenge())
        |> post(~p"/users/log_in", %{
          "webauthn_user" => %{
            "clientDataJSON" => "client_data_json",
            # base64 data
            "authenticatorData" => "VGVzdERhdGE=",
            "signature" => "VGVzdERhdGE=",
            "rawID" => "credential_id",
            "type" => "public-key",
            "userHandle" => user.id
          }
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == ~p"/app"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/app")
      response = html_response(conn, 200)
      assert response =~ user.email
      assert response =~ ~p"/users/settings"
      assert response =~ ~p"/users/log_out"
    end

    test "emmits error: passkey error", %{conn: conn, user: user, credential: _credential} do
      # Mocking So That Can Test Passkeys
      Wax
      |> stub(:authenticate, fn _u, _v, _w, _x, _y, _z -> :stub end)
      |> expect(:authenticate, fn _u, _v, _w, _x, _y, _z ->
        {:error, %Wax.ExpiredChallengeError{}}
      end)

      conn =
        conn
        # |> put_session(:authentication_challenge, Wax.new_authentication_challenge())
        |> post(~p"/users/log_in", %{
          "webauthn_user" => %{
            "clientDataJSON" => "client_data_json",
            # base64 data
            "authenticatorData" => "VGVzdERhdGE=",
            "signature" => "VGVzdERhdGE=",
            "rawID" => "credential_id",
            "type" => "public-key",
            "userHandle" => user.id
          }
        })

      assert redirected_to(conn) == ~p"/users/log_in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Authentication failed"
    end

    test "emmits error: passkey with user id not found", %{
      conn: conn,
      user: _user,
      credential: _credential
    } do
      # Mocking So That Can Test Passkeys
      Wax
      |> stub(:authenticate, fn _u, _v, _w, _x, _y, _z -> :stub end)
      |> expect(:authenticate, fn _u, _v, _w, _x, _y, _z -> {:ok, :ok} end)

      conn =
        conn
        # |> put_session(:authentication_challenge, Wax.new_authentication_challenge())
        |> post(~p"/users/log_in", %{
          "webauthn_user" => %{
            "clientDataJSON" => "client_data_json",
            # base64 data
            "authenticatorData" => "VGVzdERhdGE=",
            "signature" => "VGVzdERhdGE=",
            "rawID" => "credential_id",
            "type" => "public-key",
            "userHandle" => "AqylXz"
          }
        })

      assert redirected_to(conn) == ~p"/users/log_in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
    end
  end
end
