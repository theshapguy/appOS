defmodule Planet.Payments.PaddleHandler do
  alias Planet.Payments.Plans
  alias Planet.Subscriptions
  alias Planet.Organizations

  require Logger

  # - subscription_payment_succeeded
  # - subscription_created
  # - subscription_cancelled
  # subscription_payment_failed
  # subscription_payment_refunded
  # - subscription_updated

  # subscription.activated
  # subscription.created
  # subscription.canceled
  # subscription.updated
  # subscription.paused

  def handler(_conn, %{
        "data" =>
          %{
            # "occured_at" => occured_at,
            "next_billed_at" => _next_billed_at,
            "customer_id" => customer_id,
            "current_billing_period" => %{
              "ends_at" => ends_at,
              "starts_at" => starts_at
            },
            "id" => subscription_id,
            "custom_data" => %{
              "organization_id" => organization_id
              # "product_id" => product_id,
              # "price_id" => price_id
            }
          } = data_params,
        "event_type" => "subscription.activated"
      }) do
    organization = Organizations.get_organization!(organization_id)
    subscription = organization.subscription

    subscription_attrs =
      webhook_params_to_subscription_attrs(data_params)
      |> Map.put("issued_at", convert_paddle_webhook_datetime(starts_at))
      |> Map.put("valid_until", convert_paddle_webhook_datetime(ends_at))
      |> Map.put("customer_id", customer_id)
      |> Map.put("subscription_id", subscription_id)

    # |> Map.put("payment_attempt", nil)

    Subscriptions.update_subscription(subscription, subscription_attrs)
  end

  # def handler(_conn, %{
  #       "data" =>
  #         %{
  #           # "occured_at" => occured_at,
  #           "next_billed_at" => _next_billed_at,
  #           "customer_id" => customer_id,
  #           "id" => subscription_id,
  #           "custom_data" => %{
  #             "organization_id" => organization_id
  #           },
  #           "current_billing_period" => %{
  #             "ends_at" => ends_at,
  #             "starts_at" => starts_at
  #           }
  #         } = data_params,
  #       "event_type" => "subscription.created",
  #       "occurred_at" => _occured_at
  #     }) do
  #   organization = Organizations.get_organization!(organization_id)
  #   subscription = organization.subscription

  #   subscription_attrs =
  #     webhook_params_to_subscription_attrs(data_params)
  #     |> Map.put("issued_at", convert_paddle_webhook_datetime(starts_at))
  #     |> Map.put("valid_until", convert_paddle_webhook_datetime(ends_at))
  #     |> Map.put("customer_id", customer_id)
  #     |> Map.put("subscription_id", subscription_id)
  #     |> Map.put("payment_attempt", nil)

  #   Subscriptions.update_subscription(subscription, subscription_attrs)
  # end

  def handler(_conn, %{
        "data" =>
          %{
            "customer_id" => _customer_id,
            "id" => _subscription_id,
            "custom_data" => %{
              "organization_id" => organization_id
            }
          } = _data_params,
        "event_type" => "subscription.paused"
      }) do
    organization = Organizations.get_organization!(organization_id)
    subscription = organization.subscription

    Subscriptions.update_subscription(
      subscription,
      Plans.free_default_plan_as_subscription_attrs()
    )
  end

  def handler(_conn, %{
        "data" =>
          %{
            # "occured_at" => occured_at,

            "customer_id" => _customer_id,
            "id" => _subscription_id,
            "canceled_at" => _canceled_at,
            "custom_data" => %{
              "organization_id" => organization_id
            }
          } = _data_params,
        "event_type" => "subscription.canceled"
      }) do
    organization = Organizations.get_organization!(organization_id)
    subscription = organization.subscription

    Subscriptions.update_subscription(
      subscription,
      Plans.free_default_plan_as_subscription_attrs()
    )
  end

  # def handler(_conn, %{
  #       "data" =>
  #         %{
  #           # "occured_at" => occured_at,
  #           "next_billed_at" => _next_billed_at,
  #           "customer_id" => customer_id,
  #           "id" => subscription_id,
  #           "custom_data" => %{
  #             "organization_id" => organization_id
  #           },
  #           "current_billing_period" => %{
  #             "ends_at" => _ends_at,
  #             "starts_at" => starts_at
  #           },
  #           # If Scheduled Change Is Not Nil
  #           "scheduled_change" => %{
  #             "effective_at" => effective_at
  #           }
  #         } = data_params,
  #       "event_type" => "subscription.updated",
  #       "occurred_at" => _occured_at
  #     }) do
  #   # Status Cancelled Hence no Valid Until Date, Dont update the database value

  #   organization = Organizations.get_organization!(organization_id)
  #   subscription = organization.subscription

  #   subscription_attrs =
  #     webhook_params_to_subscription_attrs(data_params)
  #     |> Map.put("issued_at", convert_paddle_webhook_datetime(starts_at))
  #     |> Map.put("valid_until", convert_paddle_webhook_datetime(effective_at))
  #     |> Map.put("customer_id", customer_id)
  #     |> Map.put("subscription_id", subscription_id)
  #     |> Map.put("payment_attempt", nil)

  #   # |> Map.put("update_url", "https://sandbox-api.paddle.com/subscriptions/#{subscription_id}")
  #   # |> Map.put("cancel_url", "https://sandbox-api.paddle.com/subscriptions/#{subscription_id}")

  #   Subscriptions.update_subscription(subscription, subscription_attrs)
  # end

  def handler(_conn, %{
        "data" =>
          %{
            # "occured_at" => occured_at,
            "next_billed_at" => _next_billed_at,
            "customer_id" => customer_id,
            "id" => subscription_id,
            "custom_data" => %{
              "organization_id" => organization_id
            },
            "current_billing_period" => %{
              "ends_at" => ends_at,
              "starts_at" => starts_at
            }
          } = data_params,
        "event_type" => "subscription.updated"
      }) do
    organization = Organizations.get_organization!(organization_id)
    subscription = organization.subscription

    subscription_attrs =
      webhook_params_to_subscription_attrs(data_params)
      |> Map.put("issued_at", convert_paddle_webhook_datetime(starts_at))
      |> Map.put("valid_until", convert_paddle_webhook_datetime(ends_at))
      |> Map.put("customer_id", customer_id)
      |> Map.put("subscription_id", subscription_id)
      |> Map.put("payment_attempt", nil)

    # |> Map.put("update_url", "https://sandbox-api.paddle.com/subscriptions/#{subscription_id}")
    # |> Map.put("cancel_url", "https://sandbox-api.paddle.com/subscriptions/#{subscription_id}")

    Subscriptions.update_subscription(subscription, subscription_attrs)
  end

  # For Lifetime Plans Hence, Subsription_Id Nil
  def handler(_conn, %{
        "data" =>
          %{
            # "occured_at" => occured_at,
            "billed_at" => billed_at,
            "customer_id" => customer_id,
            "id" => transaction_id,
            "custom_data" => %{
              "organization_id" => organization_id
            },
            "billing_period" => nil,
            "subscription_id" => nil
          } = data_params,
        "event_type" => "transaction.completed"
      }) do
    organization = Organizations.get_organization!(organization_id)
    subscription = organization.subscription

    subscription_attrs =
      webhook_params_to_subscription_attrs(data_params)
      |> Map.put("issued_at", convert_paddle_webhook_datetime(billed_at))
      # Giving lifetime validity
      |> Map.put("valid_until", DateTime.utc_now() |> DateTime.add(3_153_600_000, :second))
      |> Map.put("customer_id", customer_id)
      |> Map.put("subscription_id", transaction_id)
      |> Map.put("payment_attempt", nil)
      |> Map.put("status", "active")

    Subscriptions.update_subscription(subscription, subscription_attrs)
  end

  def handler(
        _conn,
        %{"event_type" => _event_type} = params
      ) do
    Logger.info(params)
    :unhandled
  end

  defp webhook_params_to_subscription_attrs(params) do
    %{
      "custom_data" => %{
        "product_id" => product_id,
        "price_id" => price_id
      }
    } = params

    # items =
    #   Map.get(params, "items")
    #   |> List.first()

    # product_id =
    #   items
    #   |> Map.get("product", %{})
    #   |> Map.get("id", "default")

    # price_id =
    #   items
    #   |> Map.get("price", %{})
    #   |> Map.get("id", "default")

    %{
      # Required
      "status" => Map.get(params, "status", "past_due"),
      "product_id" => product_id,
      "price_id" => price_id,
      "processor" => "paddle"
    }
  end

  def convert_paddle_webhook_datetime(nil) do
    Timex.now()
  end

  def convert_paddle_webhook_datetime(datetime_str) do
    Timex.parse!(datetime_str, "{RFC3339}")
  end
end
