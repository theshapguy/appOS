defmodule Planet.Workers.CancelSubscription do
  @moduledoc """
  This module is responsible for canceling a subscription on
  the respective payment processor. This is done after
  user upgrades to a lifetime plan.
  """

  use Oban.Worker, queue: :cancel_subscription
  require Logger

  alias Planet.Payments.Stripe
  alias Planet.Payments.Paddle
  alias Planet.Payments.Creem

  @impl Oban.Worker
  def perform(%{
        args: %{
          "subscription_id" => nil
        }
      }) do
    # "Cancel Subscription Not Required As No Previous Subscription"
    {:ok, :no_previous_subscription}
  end

  @impl Oban.Worker
  def perform(%{
        args: %{
          "subscription_id" => subscription_id,
          "customer_id" => _customer_id,
          "processor" => "stripe"
        }
      }) do
    Stripe.request_delete(subscription_id,
      "cancellation_details[comment]": "Code: [CTLP] - Converting to Lifetime Plan"
    )
  end

  @impl Oban.Worker
  def perform(%{
        args:
          %{
            "subscription_id" => subscription_id,
            "customer_id" => _customer_id,
            "processor" => "paddle"
          } =
            _args
      }) do
    Paddle.request_post(subscription_id, %{
      "effective_from" => "immediately"
    })
  end

  @impl Oban.Worker
  def perform(%{
        args: %{
          "subscription_id" => subscription_id,
          "customer_id" => _customer_id,
          "processor" => "creem"
        }
      }) do
    Creem.request_post(subscription_id)
  end
end
