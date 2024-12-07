defmodule Planet.CreemHandlerTest do
  use Planet.DataCase

  alias Planet.Payments.CreemHandler
  alias Planet.Subscriptions.Subscription

  import Planet.CreemWebhookFixtures
  import Planet.AccountsFixtures

  describe "creem billing handler" do
    setup do
      %{user: user_fixture()}
    end

    test "creem event: subscription.paid", %{user: u} do
      {:ok, %Subscription{} = subscription} =
        CreemHandler.handler(webhook_subscription_paid(u.organization_id))

      assert subscription.status == :active

      assert subscription.issued_at == ~U[2023-02-23 13:55:22Z]
      assert subscription.valid_until == ~U[2024-02-23 13:55:22Z]

      assert subscription.customer_id == "customer_id"
      assert subscription.subscription_id == "subscription_id"

      assert subscription.product_id == "product_id"
      assert subscription.price_id == "product_id"
    end

    test "creem event: checkout.completed", %{user: u} do
      {:ok, %Subscription{} = subscription} =
        CreemHandler.handler(webhook_checkout_completed(u.organization_id))

      assert subscription.status == :active

      assert subscription.issued_at == ~U[2023-02-23 13:55:22Z]

      assert subscription.customer_id == "customer_id"
      assert subscription.subscription_id == "checkout_id"

      assert subscription.product_id == "checkout_product_id"
      assert subscription.price_id == "checkout_product_id"
    end

    test "creem event: subscription.cancelled", %{user: u} do
      {:ok, %Subscription{} = subscription} =
        CreemHandler.handler(webhook_subscription_cancelled(u.organization_id))

      assert subscription.status == :active

      assert subscription.customer_id == nil
      assert subscription.subscription_id == nil

      assert subscription.product_id == "default"
      assert subscription.price_id == "default"
    end

    test "creem event: subscription.canceled", %{user: u} do
      {:ok, %Subscription{} = subscription} =
        CreemHandler.handler(webhook_subscription_cancelled(u.organization_id))

      assert subscription.status == :active

      assert subscription.customer_id == nil
      assert subscription.subscription_id == nil

      assert subscription.product_id == "default"
      assert subscription.price_id == "default"
    end

    test "creem event: refund.created" do
      assert :unhandled ==
               CreemHandler.handler(%{
                 "id" => "evt_61eTsJHUgInFw2BQKhTiPV",
                 "eventType" => "refund.created"
               })
    end
  end
end
