defmodule Planet.StripeHandlerTest do
  alias Planet.Subscriptions
  use Planet.DataCase

  alias Planet.Subscriptions.Subscription
  alias Planet.Payments.StripeHandler

  import Planet.AccountsFixtures
  import Planet.StripeWebhookFixtures

  describe "stripe billing handler" do
    setup do
      %{user: user_fixture()}
    end

    test "stripe event: invoice.paid", %{user: u} do
      {:ok, %Subscription{} = subscription} =
        StripeHandler.handler(webhook_invoice_paid(u.email))

      assert subscription.status == :active

      assert subscription.issued_at == ~U[2024-12-09 17:01:12Z]
      assert subscription.valid_until == ~U[2025-01-09 17:01:12Z]

      assert subscription.customer_id == "customer_id"
      assert subscription.subscription_id == "sub_subscription_id"

      assert subscription.product_id == "pro_product_id"
      assert subscription.price_id == "price_price_id"
    end

    test "stripe event: customer.subscription.deleted", %{user: u} do
      customer_id = "#{Ecto.UUID.autogenerate()}"

      {:ok, _subscription} =
        Subscriptions.update_subscription(u.organization.subscription, %{
          "customer_id" => customer_id
        })

      {:ok, %Subscription{} = subscription} =
        StripeHandler.handler(webhook_subscription_deleted(customer_id))

      assert subscription.status == :active

      assert subscription.customer_id == nil
      assert subscription.subscription_id == nil

      assert subscription.product_id == "default"
      assert subscription.price_id == "default"
    end

    test "stripe event: checkout.session.completed", %{user: user} do
      webhook_data =
        webhook_checkout_session_completed(
          user.email,
          user.organization_id
        )

      {:ok, %Subscription{} = subscription} =
        StripeHandler.handler(webhook_data)

      assert subscription.status == :active

      assert subscription.customer_id == "customer_id"
      assert subscription.subscription_id == "cs_success_id"

      assert subscription.issued_at == ~U[2025-01-09 17:01:12Z]

      assert subscription.product_id == "stripe_product_id"
      assert subscription.price_id == "_stripe_price_id"
    end

    test "stripe event: unhandled" do
      assert :unhandled ==
               StripeHandler.handler(%{"type" => "payment_method.attached"})
    end
  end
end
