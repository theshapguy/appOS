defmodule Planet.Payments.PaddleWebhookHandler do
  require Logger
  alias Planet.Subscriptions
  alias Planet.Organizations

  # """
  # Once Payment Confirmed Allow Access And Update Product ID
  # Almost same as `subscription_created`
  # """
  def handler(
        %{assigns: %{paddle_passthrough: %{"organization_id" => organization_id}}},
        %{
          "alert_name" => "subscription_payment_succeeded",
          "event_time" => event_time,
          "next_bill_date" => next_bill_date,
          "user_id" => user_id,
          "subscription_id" => subscription_id
        } = params
      ) do
    organization = Organizations.get_organization!(organization_id)
    subscription = organization.subscription

    subscription_attrs =
      webhook_params_to_subscription_attrs(params)
      |> Map.put("issued_at", convert_paddle_webhook_datetime(event_time))
      |> Map.put("valid_until", convert_paddle_webhook_date(next_bill_date))
      |> Map.put("customer_id", user_id)
      |> Map.put("subscription_id", subscription_id)
      |> Map.put("payment_attempt", nil)

    # IO.inspect(subscription_attrs)

    Subscriptions.update_subscription(subscription, subscription_attrs)
  end

  # """
  # Sent as First Hook, Saving so that Update URL of Paddle Can Be Used

  # Almost same as `subscription_payment_succeeded`
  # """
  def handler(
        %{assigns: %{paddle_passthrough: %{"organization_id" => organization_id}}},
        %{
          "alert_name" => "subscription_created",
          "event_time" => event_time,
          "next_bill_date" => next_bill_date,
          "user_id" => user_id,
          "subscription_id" => subscription_id,
          "update_url" => update_url,
          "cancel_url" => cancel_url
        } = params
      ) do
    organization = Organizations.get_organization!(organization_id)
    subscription = organization.subscription

    subscription_attrs =
      webhook_params_to_subscription_attrs(params)
      |> Map.put("issued_at", convert_paddle_webhook_datetime(event_time))
      |> Map.put("valid_until", convert_paddle_webhook_date(next_bill_date))
      |> Map.put("customer_id", user_id)
      |> Map.put("subscription_id", subscription_id)
      |> Map.put("payment_attempt", nil)
      |> Map.put("update_url", update_url)
      |> Map.put("cancel_url", cancel_url)

    Subscriptions.update_subscription(subscription, subscription_attrs)
  end

  # """
  # Subscription Cancelled; Return to Default Plan
  # """
  def handler(
        %{assigns: %{paddle_passthrough: %{"organization_id" => organization_id}}},
        %{
          "alert_name" => "subscription_cancelled",
          "cancellation_effective_date" => cancelled_date,
          "event_time" => event_time,
          "user_id" => customer_id
        } = params
      ) do
    organization = Organizations.get_organization!(organization_id)
    subscription = organization.subscription

    subscription_attrs =
      webhook_params_to_subscription_attrs(params)
      # Clear It When Subscription Deleted
      # |> Map.put("paddle", [])
      # |> Map.put("cancelled_at", nil)
      |> Map.put("issued_at", convert_paddle_webhook_datetime(event_time))
      |> Map.put("valid_until", convert_paddle_webhook_date(cancelled_date))
      |> Map.put("customer_id", customer_id)
      |> Map.put("subscription_id", nil)
      # Converting to Free Plan
      |> Map.put("product_id", "default")
      |> Map.put("payment_attempt", nil)
      # Active Because Changed Product ID to Default
      |> Map.put("status", "unpaid")
      # Reupdate processor when subscription deleted, not longer paddle processor
      |> Map.put("processor", "manual")
      |> Map.put("update_url", nil)
      |> Map.put("cancel_url", nil)

    Subscriptions.update_subscription(subscription, subscription_attrs)
  end

  # """
  # Update Payment Attempt Count; if Not Nil Should Show Error On UI
  # """
  def handler(
        %{assigns: %{paddle_passthrough: %{"organization_id" => organization_id}}},
        %{
          "alert_name" => "subscription_payment_failed",
          "attempt_number" => attempt_number
        } = params
      ) do
    organization = Organizations.get_organization!(organization_id)
    subscription = organization.subscription

    subscription_attrs =
      webhook_params_to_subscription_attrs(params)
      |> Map.put("payment_attempt", attempt_number)

    Subscriptions.update_subscription(subscription, subscription_attrs)
  end

  # """
  # When payment is refunded; return to free default plan
  # """
  def handler(
        %{assigns: %{paddle_passthrough: %{"organization_id" => organization_id}}},
        %{
          "alert_name" => "subscription_payment_refunded",
          "event_time" => event_time
        } = params
      ) do
    organization = Organizations.get_organization!(organization_id)
    subscription = organization.subscription

    subscription_attrs =
      webhook_params_to_subscription_attrs(params)
      # Clear It When Subscription Deleted
      # |> Map.put("paddle", [params])
      # |> Map.put("cancelled_at", nil)
      |> Map.put("issued_at", convert_paddle_webhook_datetime(event_time))
      |> Map.put("valid_until", convert_paddle_webhook_datetime(event_time))
      # |> Map.put("customer_id", nil)
      |> Map.put("subscription_id", nil)
      # Converting to Free Plan
      |> Map.put("product_id", "default")
      |> Map.put("payment_attempt", nil)
      |> Map.put("status", "unpaid")
      |> Map.put("update_url", nil)
      |> Map.put("cancel_url", nil)

    Subscriptions.update_subscription(subscription, subscription_attrs)
  end

  # """
  # When plan has been upgraded or downgraded
  # User cannot do this from UI, has to request me to change plan and link is
  # sent to them
  # """
  def handler(
        %{assigns: %{paddle_passthrough: %{"organization_id" => organization_id}}},
        %{
          "alert_name" => "subscription_updated",
          "event_time" => event_time,
          "next_bill_date" => next_bill_date,
          "user_id" => user_id,
          "subscription_id" => subscription_id,
          "update_url" => update_url,
          "cancel_url" => cancel_url
        } = params
      ) do
    organization = Organizations.get_organization!(organization_id)
    subscription = organization.subscription

    subscription_attrs =
      webhook_params_to_subscription_attrs(params)
      |> Map.put("issued_at", convert_paddle_webhook_datetime(event_time))
      |> Map.put("valid_until", convert_paddle_webhook_date(next_bill_date))
      |> Map.put("customer_id", user_id)
      |> Map.put("subscription_id", subscription_id)
      |> Map.put("payment_attempt", nil)
      |> Map.put("update_url", update_url)
      |> Map.put("cancel_url", cancel_url)

    Subscriptions.update_subscription(subscription, subscription_attrs)
  end

  def handler(
        _conn,
        %{"alert_name" => _} = params
      ) do
    Logger.info(params)
    :unhandled
  end

  defp webhook_params_to_subscription_attrs(params) do
    %{
      # Required
      "status" => Map.get(params, "status", "past_due"),
      "product_id" => Map.get(params, "subscription_plan_id", nil),
      "processor" => "paddle"
    }
  end

  defp convert_paddle_webhook_datetime(datetime_str) do
    # IO.inspect(datetime_str)

    # Calendar.strftime(
    # datetime_str,
    # "%Y-%m-%d %X"
    # )

    Timex.parse!(datetime_str, "{YYYY}-{0M}-{0D} {h24}:{m}:{s}")
  end

  defp convert_paddle_webhook_date(date) do
    # IO.inspect(date)

    # Calendar.strftime(
    #   date,
    #   "%Y-%m-%d %X"
    # )

    Timex.parse!(date, "{YYYY}-{0M}-{0D}")
  end
end
