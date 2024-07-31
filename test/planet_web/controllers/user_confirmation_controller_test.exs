defmodule PlanetWeb.UserConfirmationControllerTest do
  use PlanetWeb.ConnCase, async: true

  alias Planet.Accounts
  alias Planet.Repo
  import Planet.AccountsFixtures

  setup do
    %{user: user_fixture(), user2: user_fixture()}
  end

  describe "GET /users/confirm" do
    test "renders the resend confirmation page", %{conn: conn} do
      conn = get(conn, ~p"/users/confirm")
      response = html_response(conn, 200)
      assert response =~ "Resend confirmation instructions"
    end
  end

  describe "POST /users/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/confirm", %{
          "user" => %{"email" => user.email}
        })

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "confirm"
    end

    test "does not send confirmation token if User is confirmed", %{conn: conn, user: user} do
      Repo.update!(Accounts.User.confirm_changeset(user))

      conn =
        post(conn, ~p"/users/confirm", %{
          "user" => %{"email" => user.email}
        })

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      refute Repo.get_by(Accounts.UserToken, user_id: user.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/users/confirm", %{
          "user" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.all(Accounts.UserToken) == []
    end
  end

  describe "GET /users/confirm/:token" do
    test "renders the confirmation page", %{conn: conn} do
      token_path = ~p"/users/confirm/some-token"
      conn = get(conn, token_path)
      response = html_response(conn, 200)
      assert response =~ "Confirm Your Account"

      assert response =~ "action=\"#{token_path}\""
    end
  end

  describe "POST /users/confirm/:token" do
    test "confirms the given token once", %{conn: conn, user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      conn = post(conn, ~p"/users/confirm/#{token}")
      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "User confirmed successfully"

      assert Accounts.get_user!(user.id).confirmed_at
      refute get_session(conn, :user_token)
      assert Repo.all(Accounts.UserToken) == []

      # When not logged in
      conn = post(conn, ~p"/users/confirm/#{token}")
      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "User confirmation link is invalid or it has expired"

      # When logged in
      conn =
        build_conn()
        |> log_in_user(user)
        |> post(~p"/users/confirm/#{token}")

      assert redirected_to(conn) == ~p"/"
      refute Phoenix.Flash.get(conn.assigns.flash, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, user: user} do
      conn = post(conn, ~p"/users/confirm/oops")
      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "User confirmation link is invalid or it has expired"

      refute Accounts.get_user!(user.id).confirmed_at
    end
  end

  describe "GET /users/confirm/invite/:token" do
    test "renders the invite confirmation page", %{conn: conn, user: user, user2: user2} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_invite_instructions(user, user2, url)
        end)

      token_path = ~p"/users/confirm/invite/#{token}"
      conn = get(conn, token_path)
      response = html_response(conn, 200)
      assert response =~ "Confirm Invite"

      assert response =~ "Accept Invite & Create Account"
      assert response =~ "#{user.email}"
    end

    test "does not render and redirects with invalid token", %{
      conn: conn
    } do
      token_path = ~p"/users/confirm/invite/some-token"

      conn = get(conn, token_path)
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "PUT /users/confirm/invite/:token" do
    setup %{user: user, user2: user2} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_invite_instructions(user, user2, url)
        end)

      %{token: token}
    end

    test "accepts invite once", %{conn: conn, user: user, token: token} do
      conn =
        put(conn, ~p"/users/confirm/invite/#{token}", %{
          "user" => %{
            "email" => "#{user.email}",
            "password" => "password_accept_invite"
          }
        })

      assert redirected_to(conn) == ~p"/users/log_in"
      refute get_session(conn, :user_token)

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Invite accepted successfully."

      assert Accounts.get_user_by_email_and_password(user.email, "password_accept_invite")
    end

    test "does not accept invite on invalid data", %{conn: conn, user: user, token: token} do
      conn =
        put(conn, ~p"/users/confirm/invite/#{token}", %{
          "user" => %{
            "email" => "#{user.email}",
            "password" => "short"
          }
        })

      assert html_response(conn, 200) =~ "something went wrong"
    end

    test "does not accept invite with invalid token", %{conn: conn, user: user} do
      conn =
        put(conn, ~p"/users/confirm/invite/invalid-token", %{
          "user" => %{
            "email" => "#{user.email}",
            "password" => "password-accepted"
          }
        })

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Invite link is invalid or it has expired"
    end
  end
end
