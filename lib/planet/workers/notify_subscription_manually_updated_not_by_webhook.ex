defmodule Planet.Workers.NotifySubscriptionManuallyUpdatedNotByWebhook do
  @moduledoc """
  In essence, this worker is responsible for notifying the user
  that their subscription was updated manually, and not by a webhook.

  Subscription.activate_subscription/1 is called to activate the subscription

  Usually happens when the webhook is not fast enough to update the subscription
  but user has paid so we need to activate the subscription manually.
  """
  use Oban.Worker, queue: :default
  require Logger

  alias Planet.Utils.Nfty
  alias Planet.Subscriptions

  def insert_job(%{"id" => _subscription_id} = args) do
    args
    |> new(
      schedule_in: 60 * 60 * 24,
      max_attempts: 3,
      unique: true
    )
    |> Oban.insert!()
  end

  @impl Oban.Worker
  def perform(%{
        args: %{
          "id" => subscription_id
        }
      }) do
    subscription = Subscriptions.get_subscription(subscription_id)
    # Can be nil if subscription is updated then removed before 1 day,
    # This case is not cheked here, as it is not a critical issue

    case subscription do
      %{processor: :manual} ->
        # Even after 1 day the subscription is still manual, so probably some issue
        # Notify admin that their subscription is still manual
        Nfty.notify(subscription)

      _ ->
        # It is not longer a manual subscription, so updated by webhook anymore
        # No further action required
        :ok
    end
  end
end
