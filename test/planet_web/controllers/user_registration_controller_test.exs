defmodule PlanetWeb.UserRegistrationControllerTest do
  alias Planet.Plugs.SubscriptionCheck
  use PlanetWeb.ConnCase, async: true

  import Planet.AccountsFixtures

  describe "GET /users/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, ~p"/users/register")
      response = html_response(conn, 200)
      assert response =~ "Sign Up"
      assert response =~ ~p"/users/log_in"
      assert response =~ ~p"/users/register"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_user(user_fixture()) |> get(~p"/users/register")

      assert redirected_to(conn) == ~p"/app"
    end
  end

  describe "POST /users/register" do
    @tag :capture_log
    test "creates account and logs the user in", %{conn: conn} do
      email = unique_user_email()

      conn =
        post(conn, ~p"/users/register", %{
          "user" => valid_user_attributes(email: email)
        })

      assert get_session(conn, :user_token)

      case SubscriptionCheck.check_allow_unpaid_access() do
        false ->
          # If Paid Plans Only, Redirect To Billing Page
          assert redirected_to(conn) == ~p"/users/billing/signup"
          conn = get(conn, ~p"/app")
          assert redirected_to(conn) == ~p"/users/billing/signup"

        true ->
          # If Free Plans Allowed, Redirect To App
          conn = get(conn, ~p"/app")
          response = html_response(conn, 200)
          assert response =~ email
          assert response =~ ~p"/users/settings"
          assert response =~ ~p"/users/log_out"
      end
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, ~p"/users/register", %{
          "user" => %{"email" => "with spaces", "password" => "too short"}
        })

      response = html_response(conn, 200)
      assert response =~ "Sign Up"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 12 character"
    end
  end
end
