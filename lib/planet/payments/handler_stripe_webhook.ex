defmodule Planet.Payments.StripeHandler do
  require Logger

  alias Planet.Payments.Plans
  alias Planet.Subscriptions
  alias Planet.Accounts
  alias Planet.Workers.CancelSubscription

  def handler(%{
        "type" => "invoice.paid",
        "data" => %{
          "object" => %{
            "customer" => customer_id,
            "customer_email" => customer_email,
            "billing_reason" => _billing_reason,
            "lines" => %{
              "data" => [
                %{
                  "period" => %{
                    "start" => period_start,
                    "end" => period_end
                  },
                  "price" => %{
                    "id" => price_id,
                    "product" => product_id
                  },
                  "subscription" => subscription_id
                }
                | _rest
              ]
            }
          }
        }
      }) do
    user = Accounts.get_user_by_email(customer_email, :subscription)
    subscription = user.organization.subscription

    # Don't Update Subscription as it is a Lifetime Plan
    # Mostly affected because cancellation can remove lifetime plan

    # Subscription Cancellation Takes Place After Lifetime Upgrade Completed
    case Plans.is_lifetime_plan?(subscription) do
      true ->
        # Do not update lifetime subscription
        {:ok, %{"customer_already_in_lifetime_plan_cannot_edit_further" => true}}

      false ->
        subscription_attrs =
          %{}
          |> Map.put("issued_at", convert_stripe_webhook_datetime(period_start))
          |> Map.put("valid_until", convert_stripe_webhook_datetime(period_end))
          |> Map.put("customer_id", customer_id)
          |> Map.put("subscription_id", subscription_id)
          |> Map.put("product_id", product_id)
          |> Map.put("price_id", price_id)
          |> Map.put("payment_attempt", nil)
          |> Map.put("status", "active")
          |> Map.put("processor", "stripe")

        Subscriptions.update_subscription(subscription, subscription_attrs)
    end
  end

  def handler(%{
        "type" => "customer.subscription.deleted",
        "data" => %{
          "object" => %{
            "customer" => customer_id,
            "canceled_at" => _canceled_at,
            "current_period_start" => _period_start
          }
        }
      }) do
    subscription = Subscriptions.get_subscription_by_customer_id(customer_id)

    case Plans.is_lifetime_plan?(subscription) do
      true ->
        # Do not update lifetime subscription
        {:ok, %{"customer_already_in_lifetime_plan_cannot_edit_further" => true}}

      false ->
        Planet.Subscriptions.update_subscription(
          subscription,
          Plans.free_default_plan_as_subscription_attrs()
        )
    end
  end

  # Only Do This For Lifetime subscritpions, hence, no need to update the subscription
  # Denoted by "mode" "payment"
  def handler(%{
        "type" => "checkout.session.completed",
        "data" => %{
          "object" => %{
            "id" => id,
            "customer" => customer_id,
            # "customer_email" => customer_email,
            "customer_details" => %{
              "email" => customer_email
            },
            "created" => created,
            "metadata" => %{
              "price_id" => price_id,
              "product_id" => product_id,
              "organization_id" => _organization_id
            },
            # Possible_values: https://docs.stripe.com/api/checkout/sessions/create#create_checkout_session-mode
            "mode" => "payment"
          }
        }
      }) do
    user = Accounts.get_user_by_email(customer_email, :subscription)
    subscription = user.organization.subscription

    case Plans.is_lifetime_plan?(subscription) do
      true ->
        # Do not update lifetime subscription
        {:ok, %{"customer_already_in_lifetime_plan_cannot_edit_further" => true}}

      false ->
        subscription_attrs =
          %{}
          |> Map.put(
            "issued_at",
            convert_stripe_webhook_datetime(created)
          )
          # Make lifetime subscription active till NOW + 100 years
          |> Map.put(
            "valid_until",
            convert_stripe_webhook_datetime(created) |> DateTime.add(3_153_600_000, :second)
          )
          |> Map.put("customer_id", customer_id)
          |> Map.put("subscription_id", id)
          |> Map.put("product_id", product_id)
          |> Map.put("price_id", price_id)
          |> Map.put("payment_attempt", nil)
          |> Map.put("status", "active")
          |> Map.put("processor", "stripe")

        %{
          "customer_id" => customer_id,
          "subscription_id" => subscription.subscription_id,
          "processor" => "stripe"
        }
        |> CancelSubscription.new()
        |> Oban.insert()

        Subscriptions.update_subscription(subscription, subscription_attrs)
    end
  end

  def handler(%{"type" => _} = params) do
    Logger.info(params)
    :unhandled
  end

  defp convert_stripe_webhook_datetime(epoch_time) do
    Timex.from_unix(epoch_time)
  end
end
