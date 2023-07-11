defmodule AppOSWeb.SubscriptionControllerTest do
  use AppOSWeb.ConnCase, async: true

  describe "GET /users/billing/" do
    setup :register_and_log_in_user

    test "renders subscription page", %{conn: conn} do
      conn = get(conn, ~p"/users/billing")
      response = html_response(conn, 200)
      assert response =~ "Billing & Subscription Settings"

      assert response =~ "Subscribe"
      assert response =~ "Current Plan"
      assert response =~ "Test Plan $$"

      assert response != "http://cancel_url"
      assert response != "http://update_url"

      assert response != "Your next payment"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, ~p"/users/billing")
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "GET /users/billing" do
    setup :register_and_log_in_paid_user

    test "renders subscription page with user subscribed plan", %{conn: conn} do
      conn = get(conn, ~p"/users/billing")
      response = html_response(conn, 200)
      assert response =~ "Billing & Subscription Settings"

      assert response =~ "Current Plan"
      assert response =~ "Test Plan $$"

      assert response =~ "http://cancel_url"
      assert response =~ "http://update_url"

      assert response =~ "Your next payment"
      assert response =~ "cancel your subscription"

      assert response != "Subscribe"
    end
  end
end
