defmodule Planet.Payments.CreemHandler do
  alias Planet.Payments.Plans
  alias Planet.Subscriptions
  alias Planet.Organizations
  alias Planet.Workers.CancelSubscription

  require Logger

  def handler(%{
        "eventType" => "subscription.paid",
        "object" => %{
          "id" => subscription_id,
          "customer" => %{
            "id" => customer_id
          },
          "metadata" => %{
            "product_id" => product_id,
            "organization_id" => organization_id
          },
          "current_period_start_date" => period_start,
          "current_period_end_date" => period_end,
          "status" => "active"
        }
      }) do
    organization = Organizations.get_organization!(organization_id)
    subscription = organization.subscription

    case Plans.webhook_check_is_lifetime_plan?(subscription) do
      true ->
        {:ok, %{"customer_already_in_lifetime_plan_cannot_edit_further" => true}}

      false ->
        subscription_attrs =
          %{}
          |> Map.put("issued_at", convert_creem_webhook_datetime(period_start))
          |> Map.put("valid_until", convert_creem_webhook_datetime(period_end))
          |> Map.put("customer_id", customer_id)
          |> Map.put("subscription_id", subscription_id)
          |> Map.put("product_id", product_id)
          |> Map.put("price_id", product_id)
          |> Map.put("payment_attempt", nil)
          |> Map.put("status", "active")
          |> Map.put("processor", "creem")
          |> Map.put("paid_once?", true)

        Subscriptions.update_subscription(subscription, subscription_attrs)
    end
  end

  def handler(%{
        "eventType" => "checkout.completed",
        "object" => %{
          "order" => %{
            "type" => "onetime",
            "created_at" => created_at
          },
          "id" => checkout_id,
          "customer" => %{
            "id" => customer_id
          },
          "metadata" => %{
            "product_id" => product_id,
            "organization_id" => organization_id
          }
        }
      }) do
    organization = Organizations.get_organization!(organization_id)
    subscription = organization.subscription

    case Plans.webhook_check_is_lifetime_plan?(subscription) do
      true ->
        {:ok, %{"customer_already_in_lifetime_plan_cannot_edit_further" => true}}

      false ->
        subscription_attrs =
          %{}
          |> Map.put(
            "issued_at",
            convert_creem_webhook_datetime(created_at)
          )
          # Make lifetime subscription active till NOW + 100 years
          |> Map.put(
            "valid_until",
            convert_creem_webhook_datetime(created_at) |> DateTime.add(3_153_600_000, :second)
          )
          |> Map.put("customer_id", customer_id)
          |> Map.put("subscription_id", checkout_id)
          |> Map.put("product_id", product_id)
          |> Map.put("price_id", product_id)
          |> Map.put("payment_attempt", nil)
          |> Map.put("status", "active")
          |> Map.put("processor", "creem")
          |> Map.put("paid_once?", true)

        %{
          "customer_id" => customer_id,
          "subscription_id" => subscription.subscription_id,
          "processor" => "creem"
        }
        |> CancelSubscription.new()
        |> Oban.insert()

        Subscriptions.update_subscription(subscription, subscription_attrs)
    end
  end

  def handler(%{
        "eventType" => "subscription.canceled",
        "object" => %{
          "id" => _subscription_id,
          "customer" => %{
            "id" => _customer_id
          },
          "metadata" => %{
            "product_id" => _product_id,
            "organization_id" => organization_id
          }
          # "status" => "canceled"
        }
      }) do
    organization = Organizations.get_organization!(organization_id)
    subscription = organization.subscription

    case Plans.webhook_check_is_lifetime_plan?(subscription) do
      true ->
        {:ok, %{"customer_already_in_lifetime_plan_cannot_edit_further" => true}}

      false ->
        Subscriptions.update_subscription(
          subscription,
          Plans.free_default_plan_as_subscription_attrs()
        )
    end
  end

  def handler(%{"eventType" => _} = params) do
    Logger.debug(params)
    :unhandled
  end

  def convert_creem_webhook_datetime(nil) do
    Timex.now()
  end

  def convert_creem_webhook_datetime(datetime_str) do
    Timex.parse!(datetime_str, "{RFC3339}")
  end
end
