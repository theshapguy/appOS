defmodule PlanetWeb.SubscriptionControllerTest do
  alias Planet.Payments.Stripe
  alias Planet.Payments.Paddle
  use PlanetWeb.ConnCase, async: true
  use Mimic

  describe "GET /users/billing/" do
    setup :register_and_log_in_user

    test "redirects to subscription payment page", %{conn: conn} do
      conn = get(conn, ~p"/users/billing")
      assert redirected_to(conn) == ~p"/users/billing/signup"
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

      assert response =~ "Manage your card, subscription, and billing details"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, ~p"/users/billing")
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "GET /users/billing/signup" do
    setup :register_and_log_in_user

    test "renders subscription billing page", %{conn: conn} do
      conn = get(conn, ~p"/users/billing/signup")
      response = html_response(conn, 200)
      assert response =~ "Simple Pricing"
      assert response =~ "Powered by"
      assert response =~ "Lifetime"
      assert response =~ "Upgrade"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, ~p"/users/billing")
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "GET /users/billing/verify - Paddle" do
    setup :register_and_log_in_user

    test "verify paddle payment - transaction completed", %{conn: conn, user: user} do
      # Mocking So That Can Test
      Paddle
      |> stub(:request, fn _ -> :stub end)
      |> expect(:request, fn _ ->
        {:ok,
         %{
           "data" => %{
             "status" => "completed",
             "created_at" => "2024-03-20T15:30:00Z",
             "custom_data" => %{
               "organization_id" => user.organization_id,
               "price_id" => "new_paid_price_id"
             }
           }
         }}
      end)

      conn =
        get(conn, ~p"/users/billing/verify", %{
          "transaction_id" => "txn_transaction_id",
          "processor" => "paddle"
        })

      assert redirected_to(conn) == ~p"/app?greeting=hi"
    end

    test "verify paddle payment - transaction incomplete", %{conn: conn, user: user} do
      # Mocking So That Can Test
      Paddle
      |> stub(:request, fn _ -> :stub end)
      |> expect(:request, fn _ ->
        {:ok,
         %{
           "data" => %{
             "status" => "incomplete",
             "created_at" => "2024-03-20T15:30:00Z",
             "custom_data" => %{
               "organization_id" => user.organization_id,
               "price_id" => "new_paid_price_id"
             }
           }
         }}
      end)

      conn =
        get(conn, ~p"/users/billing/verify", %{
          "transaction_id" => "txn_transaction_id",
          "processor" => "paddle"
        })

      assert redirected_to(conn) ==
               ~p"/users/billing/signup?payment_failed=1&processor=paddle&transaction_id=txn_transaction_id"
    end

    test "verify paddle payment - transaction api not sending correct data", %{
      conn: conn,
      user: user
    } do
      # Mocking So That Can Test
      Paddle
      |> stub(:request, fn _ -> :stub end)
      |> expect(:request, fn _ ->
        {:ok,
         %{
           "data" => %{
             "status2" => "incomplete",
             "created_at2" => "2024-03-20T15:30:00Z",
             "custom_data2" => %{
               "organization_id2" => user.organization_id
             }
           }
         }}
      end)

      conn =
        get(conn, ~p"/users/billing/verify", %{
          "transaction_id" => "txn_transaction_id",
          "processor" => "paddle"
        })

      assert redirected_to(conn) ==
               ~p"/users/billing/signup?payment_failed=1&processor=paddle&transaction_id=txn_transaction_id"
    end

    test "verify paddle payment - error connecting to paddle", %{
      conn: conn,
      user: _user
    } do
      # Mocking So That Can Test
      Paddle
      |> stub(:request, fn _ -> :stub end)
      |> expect(:request, fn _ ->
        {:error, 1}
      end)

      conn =
        get(conn, ~p"/users/billing/verify", %{
          "transaction_id" => "txn_transaction_id",
          "processor" => "paddle"
        })

      assert redirected_to(conn) ==
               ~p"/users/billing/signup?payment_failed=1&processor=paddle&transaction_id=txn_transaction_id"
    end
  end

  describe "GET /users/billing/verify - Stripe" do
    setup :register_and_log_in_user

    test "verify stripe payment - transaction completed", %{conn: conn, user: user} do
      Stripe
      |> stub(:request, fn _ -> :stub end)
      |> expect(:request, fn _ ->
        {:ok,
         %{
           "status" => "complete",
           "created" => 1_710_945_000,
           "metadata" => %{
             "organization_id" => user.organization_id,
             "price_id" => "price_1",
             "product_id" => "product_1"
           }
         }}
      end)

      conn =
        get(conn, ~p"/users/billing/verify", %{
          "session_id" => "cs_transaction_id",
          "processor" => "stripe"
        })

      assert redirected_to(conn) == ~p"/app?greeting=hi"
    end

    test "verify stripe payment - transaction incomplete", %{conn: conn, user: user} do
      Stripe
      |> stub(:request, fn _ -> :stub end)
      |> expect(:request, fn _ ->
        {:ok,
         %{
           "status" => "incomplete",
           "created" => 1_710_945_000,
           "metadata" => %{
             "organization_id" => user.organization_id,
             "price_id" => "price_1",
             "product_id" => "product_1"
           }
         }}
      end)

      conn =
        get(conn, ~p"/users/billing/verify", %{
          "session_id" => "cs_session_id",
          "processor" => "stripe"
        })

      assert redirected_to(conn) ==
               ~p"/users/billing/signup?payment_failed=1&processor=stripe&session_id=cs_session_id"
    end

    test "verify stripe payment - transaction api not sending correct data", %{
      conn: conn,
      user: user
    } do
      Stripe
      |> stub(:request, fn _ -> :stub end)
      |> expect(:request, fn _ ->
        {:ok,
         %{
           "status1" => "incomplete",
           "created1" => 1_710_945_000,
           "metadata1" => %{
             "organization_id1" => user.organization_id,
             "price_id1" => "price_1",
             "product_id1" => "product_1"
           }
         }}
      end)

      conn =
        get(conn, ~p"/users/billing/verify", %{
          "session_id" => "cs_transaction_id",
          "processor" => "stripe"
        })

      assert redirected_to(conn) ==
               ~p"/users/billing/signup?payment_failed=1&processor=stripe&session_id=cs_transaction_id"
    end

    test "verify stripe payment - error connecting to stripe", %{
      conn: conn,
      user: _user
    } do
      Stripe
      |> stub(:request, fn _ -> :stub end)
      |> expect(:request, fn _ ->
        {:error, %{}}
      end)

      conn =
        get(conn, ~p"/users/billing/verify", %{
          "session_id" => "cs_transaction_id",
          "processor" => "stripe"
        })

      assert redirected_to(conn) ==
               ~p"/users/billing/signup?payment_failed=1&processor=stripe&session_id=cs_transaction_id"
    end
  end
end
