defmodule Planet.StripeWebhookFixtures do
  def webhook_invoice_paid(email) do
    %{
      "type" => "invoice.paid",
      "data" => %{
        "object" => %{
          "customer" => "customer_id",
          "customer_email" => email,
          "billing_reason" => "subscription_create",
          "lines" => %{
            "data" => [
              %{
                "period" => %{
                  "start" => 1_733_763_672,
                  "end" => 1_736_442_072
                },
                "price" => %{
                  "id" => "price_price_id",
                  "product" => "pro_product_id"
                },
                "subscription" => "sub_subscription_id"
              }
            ]
          }
        }
      }
    }
  end

  def webhook_subscription_deleted(customer_id) do
    %{
      "type" => "customer.subscription.deleted",
      "data" => %{
        "object" => %{
          "customer" => customer_id,
          "canceled_at" => 1_736_442_072,
          "current_period_start" => 1_733_763_672
        }
      }
    }
  end

  def webhook_checkout_session_completed(customer_email, organization_id) do
    %{
      "type" => "checkout.session.completed",
      "data" => %{
        "object" => %{
          "id" => "cs_success_id",
          "customer" => "customer_id",
          # "customer_email" => customer_email,
          "customer_details" => %{
            "email" => customer_email
          },
          "created" => 1_736_442_072,
          "metadata" => %{
            "price_id" => "_stripe_price_id",
            "product_id" => "stripe_product_id",
            "organization_id" => organization_id
          },
          "mode" => "payment"
        }
      }
    }
  end
end
