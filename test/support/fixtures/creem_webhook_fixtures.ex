defmodule Planet.CreemWebhookFixtures do
  def webhook_subscription_paid(organization_id) do
    %{
      "eventType" => "subscription.paid",
      "object" => %{
        "id" => "subscription_id",
        "customer" => %{
          "id" => "customer_id"
        },
        "metadata" => %{
          "product_id" => "product_id",
          "organization_id" => organization_id
        },
        "current_period_start_date" => "2023-02-23T13:55:22.538367Z",
        "current_period_end_date" => "2024-02-23T13:55:22.538367Z",
        "status" => "active"
      }
    }
  end

  def webhook_checkout_completed(organization_id) do
    %{
      "eventType" => "checkout.completed",
      "object" => %{
        "order" => %{
          "type" => "onetime",
          "created_at" => "2023-02-23T13:55:22.538367Z"
        },
        "id" => "checkout_id",
        "customer" => %{
          "id" => "customer_id"
        },
        "metadata" => %{
          "product_id" => "checkout_product_id",
          "organization_id" => organization_id
        }
        # "status" => "canceled"
      }
    }
  end

  def webhook_subscription_cancelled(organization_id) do
    %{
      "eventType" => "subscription.canceled",
      "object" => %{
        "id" => "_subscription_id",
        "customer" => %{
          "id" => "_customer_id"
        },
        "metadata" => %{
          "product_id" => "_product_id",
          "organization_id" => organization_id
        }
      }
    }
  end
end
