defmodule AppOS.SubscriptionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AppOS.Subscriptions` context.
  """

  alias AppOS.Accounts.User

  @doc """
  Generate a subscription.
  """
  def subscription_fixture(%User{} = user, attrs \\ %{}) do
    user_subscription = user.organization.subscription

    attrs =
      attrs
      |> Enum.into(%{
        # Primary Key
        # user_id: user.id,
        product_id: "product_id",
        customer_id: "customer_id",
        subscription_id: "subscription_id",
        subscription_status: "active",
        issued_at: ~U[2023-06-27 13:59:00Z],
        valid_until: ~U[2023-07-27 13:59:00Z],
        payment_attempt: nil,
        update_url: nil,
        cancel_url: nil

        # cancel_url: "some cancel_url",
        # cancelled_at: ~U[2023-06-27 13:59:00Z],
        # customer_id: "some customer_id",
        # is_paddle: true,
        # issued_at: ~U[2023-06-27 13:59:00Z],
        # subscription_id: "some subscription_id",
        # update_url: "some update_url",
        # valid_until: ~U[2023-06-27 13:59:00Z]
      })

    {:ok, subscription} = AppOS.Subscriptions.update_subscription(user_subscription, attrs)

    subscription
  end
end
