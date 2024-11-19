defmodule Planet.Payments.PaddleBillingHandler do
  alias Planet.Subscriptions
  alias Planet.Organizations
  alias Planet.Subscriptions.Subscription

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
      |> Map.put("payment_attempt", nil)

    Subscriptions.update_subscription(subscription, subscription_attrs)
  end

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
        "event_type" => "subscription.created",
        "occurred_at" => _occured_at
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

  def handler(_conn, %{
        "data" =>
          %{
            # "occured_at" => occured_at,

            "customer_id" => customer_id,
            "id" => subscription_id,
            "custom_data" => %{
              "organization_id" => organization_id
            }
          } = data_params,
        "event_type" => "subscription.paused"
      }) do
    organization = Organizations.get_organization!(organization_id)
    subscription = organization.subscription

    subscription_attrs =
      webhook_params_to_subscription_attrs(data_params)
      # Clear It When Subscription Deleted
      # |> Map.put("paddle", [])
      # |> Map.put("cancelled_at", nil)
      # |> Map.put("issued_at", nil)
      # |> Map.put("valid_until", nil)
      |> Map.put("customer_id", customer_id)
      |> Map.put("subscription_id", subscription_id)
      # Converting to Free Plan
      |> Map.put("product_id", "default")
      |> Map.put("payment_attempt", nil)
      # Active Because Changed Product ID to Default
      |> Map.put("status", "unpaid")
      # Reupdate processor when subscription deleted, not longer paddle processor
      |> Map.put("processor", "manual")

    # |> Map.put("update_url", nil)
    # |> Map.put("cancel_url", nil)

    Subscriptions.update_subscription(subscription, subscription_attrs)
  end

  def handler(_conn, %{
        "data" =>
          %{
            # "occured_at" => occured_at,

            "customer_id" => customer_id,
            "id" => _subscription_id,
            "canceled_at" => canceled_at,
            "custom_data" => %{
              "organization_id" => organization_id
            }
          } = data_params,
        "event_type" => "subscription.canceled"
      }) do
    organization = Organizations.get_organization!(organization_id)
    subscription = organization.subscription

    subscription_attrs =
      webhook_params_to_subscription_attrs(data_params)
      # Clear It When Subscription Deleted
      # |> Map.put("paddle", [])
      # |> Map.put("cancelled_at", nil)
      # |> Map.put("issued_at", convert_paddle_webhook_datetime(occured_at))
      |> Map.put("valid_until", convert_paddle_webhook_datetime(canceled_at))
      |> Map.put("customer_id", customer_id)
      |> Map.put("subscription_id", nil)
      # Converting to Free Plan
      |> Map.put("product_id", "default")
      |> Map.put("payment_attempt", nil)
      # Active Because Changed Product ID to Default
      |> Map.put("status", "unpaid")
      # Reupdate processor when subscription deleted, not longer paddle processor
      |> Map.put("processor", "manual")

    # |> Map.put("update_url", nil)
    # |> Map.put("cancel_url", nil)

    Subscriptions.update_subscription(subscription, subscription_attrs)
  end

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
              "ends_at" => _ends_at,
              "starts_at" => starts_at
            },
            # If Scheduled Change Is Not Nil
            "scheduled_change" => %{
              "effective_at" => effective_at
            }
          } = data_params,
        "event_type" => "subscription.updated",
        "occurred_at" => _occured_at
      }) do
    # Status Cancelled Hence no Valid Until Date, Dont update the database value

    organization = Organizations.get_organization!(organization_id)
    subscription = organization.subscription

    subscription_attrs =
      webhook_params_to_subscription_attrs(data_params)
      |> Map.put("issued_at", convert_paddle_webhook_datetime(starts_at))
      |> Map.put("valid_until", convert_paddle_webhook_datetime(effective_at))
      |> Map.put("customer_id", customer_id)
      |> Map.put("subscription_id", subscription_id)
      |> Map.put("payment_attempt", nil)

    # |> Map.put("update_url", "https://sandbox-api.paddle.com/subscriptions/#{subscription_id}")
    # |> Map.put("cancel_url", "https://sandbox-api.paddle.com/subscriptions/#{subscription_id}")

    Subscriptions.update_subscription(subscription, subscription_attrs)
  end

  def handler(_conn, %{
        "data" =>
          %{
            # "occured_at" => occured_at,
            "next_billed_at" => next_billed_at,
            "customer_id" => customer_id,
            "id" => subscription_id,
            "custom_data" => %{
              "organization_id" => organization_id
            },
            "current_billing_period" => %{
              "ends_at" => _ends_at,
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
      |> Map.put("valid_until", convert_paddle_webhook_datetime(next_billed_at))
      |> Map.put("customer_id", customer_id)
      |> Map.put("subscription_id", subscription_id)
      |> Map.put("payment_attempt", nil)

    # |> Map.put("update_url", "https://sandbox-api.paddle.com/subscriptions/#{subscription_id}")
    # |> Map.put("cancel_url", "https://sandbox-api.paddle.com/subscriptions/#{subscription_id}")

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
    product_id =
      Map.get(params, "items")
      |> List.first()
      |> Map.get("product", %{})
      |> Map.get("id", nil)

    %{
      # Required
      "status" => Map.get(params, "status", "past_due"),
      "product_id" => product_id,
      "processor" => "paddle-billing"
    }
  end

  defp convert_paddle_webhook_datetime(nil) do
    Timex.now()
  end

  defp convert_paddle_webhook_datetime(datetime_str) do
    Timex.parse!(datetime_str, "{RFC3339}")
  end

  def create_portal_session(%Subscription{} = subscription) do
    api_key =
      Application.fetch_env!(:planet, :paddle)
      |> Keyword.fetch!(:billing_api_key)

    # TODO Change with the correct URL: Prod and Live
    url = "https://sandbox-api.paddle.com/customers/#{subscription.customer_id}/portal-sessions"

    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    body =
      %{
        "subscription_ids" => [subscription.subscription_id]
      }
      |> Jason.encode!()

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 201, body: response_body}} ->
        decoded_body = Jason.decode!(response_body)

        {:ok, update_subscription_with_response(subscription, decoded_body)}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Request failed with status code #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed with reason #{reason}"}
    end
  end

  def update_subscription_with_response(%Subscription{} = subscription, response) do
    %{
      "data" => %{
        "urls" => %{
          "general" => %{
            "overview" => overview_url
          },
          "subscriptions" => [
            %{
              "cancel_subscription" => cancel_url,
              "update_subscription_payment_method" => update_payment_method_url
            }
            | _
          ]
        }
      }
    } = response

    %Subscription{
      subscription
      | paddle_billing_cancel_url: cancel_url,
        paddle_billing_update_payment_url: update_payment_method_url,
        paddle_billing_overview_url: overview_url,
        cancel_url: cancel_url,
        update_url: update_payment_method_url
    }
  end
end
