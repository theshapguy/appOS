defmodule Planet.PaddleHandlerTest do
  alias Planet.Payments.Plans
  use Planet.DataCase

  import Planet.AccountsFixtures
  import Planet.PaddleWebhookFixtures

  alias Planet.Payments.PaddleHandler
  alias Planet.Subscriptions.Subscription

  # - subscription.created
  # - subscription.activated
  # - subscription.canceled
  # - subscription.updated
  # subscription.paused

  describe "paddle billing handler" do
    setup do
      %{subscription: user_fixture().organization.subscription}
    end

    # test "paddle event: subscription.created", %{subscription: s} do
    #   {:ok, %Subscription{} = subscription} =
    #     PaddleHandler.handler(
    #       nil,
    #       webhook_subscription_created(s.organization_id)
    #     )

    #   assert subscription.status == :active
    #   assert subscription.issued_at == ~U[2024-04-12 10:18:47Z]
    #   assert subscription.valid_until == ~U[2024-05-12 10:18:47Z]
    #   assert subscription.customer_id == "ctm_01hv6y1jedq4p1n0yqn5ba3ky4"
    #   assert subscription.subscription_id == "sub_01hv8x29kz0t586xy6zn1a62ny"
    #   # assert subscription.payment_attempt == nil
    #   assert subscription.product_id == "pro_01gsz4t5hdjse780zja8vvr7jg"
    # end

    test "paddle event: subscription.activated", %{subscription: s} do
      {:ok, %Subscription{} = subscription} =
        PaddleHandler.handler(
          nil,
          webhook_subscription_activated(s.organization_id)
        )

      assert subscription.status == :active
      assert subscription.issued_at == ~U[2024-04-12 10:18:47Z]
      assert subscription.valid_until == ~U[2024-05-12 10:18:47Z]
      assert subscription.customer_id == "ctm_01hv6y1jedq4p1n0yqn5ba3ky4"
      assert subscription.subscription_id == "sub_01hv8x29kz0t586xy6zn1a62ny"
      # assert subscription.payment_attempt == nil
      assert subscription.product_id == "pro_01gsz4t5hdjse780zja8vvr7jg"
    end

    test "paddle event: subscription.updated", %{subscription: s} do
      {:ok, %Subscription{} = subscription} =
        PaddleHandler.handler(
          nil,
          webhook_subscription_updated(s.organization_id)
        )

      assert subscription.status == :active
      assert subscription.customer_id == "ctm_01hv6y1jedq4p1n0yqn5ba3ky4"
      assert subscription.product_id == "pro_01gsz4t5hdjse780zja8vvr7jg"
      assert subscription.subscription_id == "sub_01hv8x29kz0t586xy6zn1a62ny"

      assert subscription.valid_until == ~U[2024-05-12T10:37:59Z]
      assert subscription.issued_at == ~U[2024-04-12 10:37:59Z]
    end

    # test "paddle event: subscription.updated intent to pause at end of billing date", %{
    #   subscription: s
    # } do
    #   {:ok, %Subscription{} = subscription} =
    #     PaddleHandler.handler(
    #       nil,
    #       webhook_subscription_updated_intent_to_pause(s.organization_id)
    #     )

    #   assert subscription.status == :active
    #   assert subscription.customer_id == "ctm_01hv6y1jedq4p1n0yqn5ba3ky4"
    #   assert subscription.product_id == "pro_01gsz4t5hdjse780zja8vvr7jg"
    #   assert subscription.subscription_id == "sub_01hv8x29kz0t586xy6zn1a62ny"

    #   assert subscription.valid_until == ~U[2024-03-12 10:37:59Z]
    #   assert subscription.issued_at == ~U[2024-04-12 10:37:59Z]
    # end

    # test "paddle event: subscription.updated intent to cancel at end of billing date", %{
    #   subscription: s
    # } do
    #   {:ok, %Subscription{} = subscription} =
    #     PaddleHandler.handler(
    #       nil,
    #       webhook_subscription_updated_intent_to_cancel(s.organization_id)
    #     )

    #   assert subscription.status == :active
    #   assert subscription.customer_id == "ctm_01hv6y1jedq4p1n0yqn5ba3ky4"
    #   assert subscription.product_id == "pro_01gsz4t5hdjse780zja8vvr7jg"
    #   assert subscription.subscription_id == "sub_01hv8x29kz0t586xy6zn1a62ny"

    #   assert subscription.valid_until == ~U[2024-03-12 10:37:59Z]
    #   assert subscription.issued_at == ~U[2024-04-12 10:37:59Z]
    # end

    test "paddle event: subscription.canceled", %{subscription: s} do
      {:ok, %Subscription{} = subscription} =
        PaddleHandler.handler(
          nil,
          webhook_subscription_canceled(s.organization_id)
        )

      %{price_id: price_id, product_id: product_id} = Plans.free_default_plan_ids()

      assert subscription.status == Plans.default_plan_subscription_status()
      assert subscription.customer_id == nil
      assert subscription.product_id == product_id
      assert subscription.price_id == price_id
      assert subscription.subscription_id == nil
      # Valid Until Days is 99 years more aways
      assert Timex.compare(subscription.valid_until, Timex.now() |> Timex.shift(years: 99)) == 1

      # Unchanged
      # assert subscription.issued_at == s.issued_at
    end

    test "paddle event: subscription.paused", %{
      subscription: s
    } do
      {:ok, %Subscription{} = subscription} =
        PaddleHandler.handler(
          nil,
          webhook_subscription_paused(s.organization_id)
        )

      %{price_id: price_id, product_id: product_id} = Plans.free_default_plan_ids()

      assert subscription.status == Plans.default_plan_subscription_status()
      assert subscription.customer_id == nil
      assert subscription.product_id == product_id
      assert subscription.price_id == price_id
      assert subscription.subscription_id == nil
      # Valid Until Days is 99 years more aways
      assert Timex.compare(subscription.valid_until, Timex.now() |> Timex.shift(years: 99)) == 1
    end

    test "paddle event unhandled: transaction.completed" do
      assert :unhandled ==
               PaddleHandler.handler(
                 nil,
                 """
                 {
                   "event_id": "ntfsimevt_01jd00tmxmnjwedtm67q3rsasd",
                   "event_type": "transaction.completed",
                   "occurred_at": "2024-11-18T16:13:55.508206Z",
                   "notification_id": "ntfsimntf_01jd00tn1afm298jhrwvnhqh9a"
                 }
                 """
                 |> Jason.decode!()
               )
    end
  end
end
