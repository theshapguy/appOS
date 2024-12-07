defmodule Planet.PaddleWebhookFixtures do
  def webhook_subscription_created(organization_id) do
    """
    {
    "event_id": "ntfsimevt_01jd00tmxmnjwedtm67q3rsasd",
    "event_type": "subscription.created",
    "occurred_at": "2024-11-18T16:13:55.508206Z",
    "notification_id": "ntfsimntf_01jd00tn1afm298jhrwvnhqh9a",
    "data": {
      "id": "sub_01hv8x29kz0t586xy6zn1a62ny",
      "items": [
        {
          "price": {
            "id": "pri_01gsz8x8sawmvhz1pv30nge1ke",
            "name": "Monthly (per seat)",
            "type": "standard",
            "status": "active",
            "quantity": {
              "maximum": 999,
              "minimum": 1
            },
            "tax_mode": "account_setting",
            "created_at": "2023-02-23T13:55:22.538367Z",
            "product_id": "pro_01gsz4t5hdjse780zja8vvr7jg",
            "unit_price": {
              "amount": "3000",
              "currency_code": "USD"
            },
            "updated_at": "2024-04-11T13:54:52.254748Z",
            "custom_data": null,
            "description": "Monthly",
            "import_meta": null,
            "trial_period": null,
            "billing_cycle": {
              "interval": "month",
              "frequency": 1
            },
            "unit_price_overrides": []
          },
          "status": "active",
          "product": {
            "id": "pro_01gsz4t5hdjse780zja8vvr7jg",
            "name": "AeroEdit Pro",
            "type": "standard",
            "status": "active",
            "image_url": "https://paddle.s3.amazonaws.com/user/165798/bT1XUOJAQhOUxGs83cbk_pro.png",
            "created_at": "2023-02-23T12:43:46.605Z",
            "updated_at": "2024-04-05T15:53:44.687Z",
            "custom_data": {
              "features": {
                "sso": false,
                "route_planning": true,
                "payment_by_invoice": false,
                "aircraft_performance": true,
                "compliance_monitoring": true,
                "flight_log_management": true
              },
              "suggested_addons": [
                "pro_01h1vjes1y163xfj1rh1tkfb65",
                "pro_01gsz97mq9pa4fkyy0wqenepkz"
              ],
              "upgrade_description": "Move from Basic to Pro to take advantage of aircraft performance, advanced route planning, and compliance monitoring."
            },
            "description": "Designed for professional pilots, including all features plus in Basic plus compliance monitoring, route optimization, and third-party integrations.",
            "import_meta": null,
            "tax_category": "standard"
          },
          "quantity": 10,
          "recurring": true,
          "created_at": "2024-04-12T10:18:48.831Z",
          "updated_at": "2024-04-12T10:18:48.831Z",
          "trial_dates": null,
          "next_billed_at": "2024-05-12T10:18:47.635628Z",
          "previously_billed_at": "2024-04-12T10:18:47.635628Z"
        },
        {
          "price": {
            "id": "pri_01h1vjfevh5etwq3rb416a23h2",
            "name": "Monthly (recurring addon)",
            "type": "standard",
            "status": "active",
            "quantity": {
              "maximum": 100,
              "minimum": 1
            },
            "tax_mode": "account_setting",
            "created_at": "2023-06-01T13:31:12.625056Z",
            "product_id": "pro_01h1vjes1y163xfj1rh1tkfb65",
            "unit_price": {
              "amount": "10000",
              "currency_code": "USD"
            },
            "updated_at": "2024-04-09T07:23:00.907834Z",
            "custom_data": null,
            "description": "Monthly",
            "import_meta": null,
            "trial_period": null,
            "billing_cycle": {
              "interval": "month",
              "frequency": 1
            },
            "unit_price_overrides": []
          },
          "status": "active",
          "product": {
            "id": "pro_01h1vjes1y163xfj1rh1tkfb65",
            "name": "Analytics addon",
            "type": "standard",
            "status": "active",
            "image_url": "https://paddle.s3.amazonaws.com/user/165798/97dRpA6SXzcE6ekK9CAr_analytics.png",
            "created_at": "2023-06-01T13:30:50.302Z",
            "updated_at": "2024-04-05T15:47:17.163Z",
            "custom_data": null,
            "description": "Unlock advanced insights into your flight data with enhanced analytics and reporting features. Includes customizable reporting templates and trend analysis across flights.",
            "import_meta": null,
            "tax_category": "standard"
          },
          "quantity": 1,
          "recurring": true,
          "created_at": "2024-04-12T10:18:48.831Z",
          "updated_at": "2024-04-12T10:18:48.831Z",
          "trial_dates": null,
          "next_billed_at": "2024-05-12T10:18:47.635628Z",
          "previously_billed_at": "2024-04-12T10:18:47.635628Z"
        }
      ],
      "status": "active",
      "discount": null,
      "paused_at": null,
      "address_id": "add_01hv8gq3318ktkfengj2r75gfx",
      "created_at": "2024-04-12T10:18:48.831Z",
      "started_at": "2024-04-12T10:18:47.635628Z",
      "updated_at": "2024-04-12T10:18:48.831Z",
      "business_id": null,
      "canceled_at": null,
      "custom_data": {
        "organization_id": "#{organization_id}",
        "price_id": "pri_01h1vjfevh5etwq3rb416a23h2",
        "product_id": "pro_01gsz4t5hdjse780zja8vvr7jg"
      },
      "customer_id": "ctm_01hv6y1jedq4p1n0yqn5ba3ky4",
      "import_meta": null,
      "billing_cycle": {
        "interval": "month",
        "frequency": 1
      },
      "currency_code": "USD",
      "next_billed_at": "2024-05-12T10:18:47.635628Z",
      "transaction_id": "txn_01hv8wptq8987qeep44cyrewp9",
      "billing_details": null,
      "collection_mode": "automatic",
      "first_billed_at": "2024-04-12T10:18:47.635628Z",
      "scheduled_change": null,
      "current_billing_period": {
        "ends_at": "2024-05-12T10:18:47.635628Z",
        "starts_at": "2024-04-12T10:18:47.635628Z"
      }
    }
    }
    """
    |> Jason.decode!()
  end

  def webhook_subscription_activated(organization_id) do
    """
    {
      "event_id": "ntfsimevt_01jczvae1wjdk7mngrngkpbeq3",
      "event_type": "subscription.activated",
      "occurred_at": "2024-11-18T14:37:41.308298Z",
      "notification_id": "ntfsimntf_01jczvae5nfhxww38bedhbcwax",
      "data": {
        "id": "sub_01hv8x29kz0t586xy6zn1a62ny",
        "items": [
          {
            "price": {
              "id": "pri_01gsz8x8sawmvhz1pv30nge1ke",
              "name": "Monthly (per seat)",
              "type": "standard",
              "status": "active",
              "quantity": {
                "maximum": 999,
                "minimum": 1
              },
              "tax_mode": "account_setting",
              "created_at": "2023-02-23T13:55:22.538367Z",
              "product_id": "pro_01gsz4t5hdjse780zja8vvr7jg",
              "unit_price": {
                "amount": "3000",
                "currency_code": "USD"
              },
              "updated_at": "2024-04-11T13:54:52.254748Z",
              "custom_data": null,
              "description": "Monthly",
              "import_meta": null,
              "trial_period": null,
              "billing_cycle": {
                "interval": "month",
                "frequency": 1
              },
              "unit_price_overrides": []
            },
            "status": "active",
            "product": {
              "id": "pro_01gsz4t5hdjse780zja8vvr7jg",
              "name": "AeroEdit Pro",
              "type": "standard",
              "status": "active",
              "image_url": "https://paddle.s3.amazonaws.com/user/165798/bT1XUOJAQhOUxGs83cbk_pro.png",
              "created_at": "2023-02-23T12:43:46.605Z",
              "updated_at": "2024-04-05T15:53:44.687Z",
              "custom_data": {
                "features": {
                  "sso": false,
                  "route_planning": true,
                  "payment_by_invoice": false,
                  "aircraft_performance": true,
                  "compliance_monitoring": true,
                  "flight_log_management": true
                },
                "suggested_addons": [
                  "pro_01h1vjes1y163xfj1rh1tkfb65",
                  "pro_01gsz97mq9pa4fkyy0wqenepkz"
                ],
                "upgrade_description": "Move from Basic to Pro to take advantage of aircraft performance, advanced route planning, and compliance monitoring."
              },
              "description": "Designed for professional pilots, including all features plus in Basic plus compliance monitoring, route optimization, and third-party integrations.",
              "import_meta": null,
              "tax_category": "standard"
            },
            "quantity": 10,
            "recurring": true,
            "created_at": "2024-04-12T10:18:48.831Z",
            "updated_at": "2024-04-12T10:18:48.831Z",
            "trial_dates": null,
            "next_billed_at": "2024-05-12T10:18:47.635628Z",
            "previously_billed_at": "2024-04-12T10:18:47.635628Z"
          },
          {
            "price": {
              "id": "pri_01h1vjfevh5etwq3rb416a23h2",
              "name": "Monthly (recurring addon)",
              "type": "standard",
              "status": "active",
              "quantity": {
                "maximum": 100,
                "minimum": 1
              },
              "tax_mode": "account_setting",
              "created_at": "2023-06-01T13:31:12.625056Z",
              "product_id": "pro_01h1vjes1y163xfj1rh1tkfb65",
              "unit_price": {
                "amount": "10000",
                "currency_code": "USD"
              },
              "updated_at": "2024-04-09T07:23:00.907834Z",
              "custom_data": null,
              "description": "Monthly",
              "import_meta": null,
              "trial_period": null,
              "billing_cycle": {
                "interval": "month",
                "frequency": 1
              },
              "unit_price_overrides": []
            },
            "status": "active",
            "product": {
              "id": "pro_01h1vjes1y163xfj1rh1tkfb65",
              "name": "Analytics addon",
              "type": "standard",
              "status": "active",
              "image_url": "https://paddle.s3.amazonaws.com/user/165798/97dRpA6SXzcE6ekK9CAr_analytics.png",
              "created_at": "2023-06-01T13:30:50.302Z",
              "updated_at": "2024-04-05T15:47:17.163Z",
              "custom_data": null,
              "description": "Unlock advanced insights into your flight data with enhanced analytics and reporting features. Includes customizable reporting templates and trend analysis across flights.",
              "import_meta": null,
              "tax_category": "standard"
            },
            "quantity": 1,
            "recurring": true,
            "created_at": "2024-04-12T10:18:48.831Z",
            "updated_at": "2024-04-12T10:18:48.831Z",
            "trial_dates": null,
            "next_billed_at": "2024-05-12T10:18:47.635628Z",
            "previously_billed_at": "2024-04-12T10:18:47.635628Z"
          }
        ],
        "status": "active",
        "discount": null,
        "paused_at": null,
        "address_id": "add_01hv8gq3318ktkfengj2r75gfx",
        "created_at": "2024-04-12T10:18:48.831Z",
        "started_at": "2024-04-12T10:18:47.635628Z",
        "updated_at": "2024-04-12T10:18:48.831Z",
        "business_id": null,
        "canceled_at": null,
        "custom_data": {
          "organization_id": "#{organization_id}",
          "price_id": "pri_01gsz8x8sawmvhz1pv30nge1ke",
          "product_id": "pro_01gsz4t5hdjse780zja8vvr7jg"
        },
        "customer_id": "ctm_01hv6y1jedq4p1n0yqn5ba3ky4",
        "import_meta": null,
        "billing_cycle": {
          "interval": "month",
          "frequency": 1
        },
        "currency_code": "USD",
        "next_billed_at": "2024-05-12T10:18:47.635628Z",
        "billing_details": null,
        "collection_mode": "automatic",
        "first_billed_at": "2024-04-12T10:18:47.635628Z",
        "scheduled_change": null,
        "current_billing_period": {
          "ends_at": "2024-05-12T10:18:47.635628Z",
          "starts_at": "2024-04-12T10:18:47.635628Z"
        }
      }
    }
    """
    |> Jason.decode!()
  end

  def webhook_subscription_canceled(organization_id) do
    """
    {
      "event_id": "ntfsimevt_01jd012razxxsz8xah8v4t0nhm",
      "event_type": "subscription.canceled",
      "occurred_at": "2024-11-18T16:18:21.151259Z",
      "notification_id": "ntfsimntf_01jd012rf6kfw6dfncx2198jw9",
      "data": {
        "id": "sub_01hv8x29kz0t586xy6zn1a62ny",
        "items": [
          {
            "price": {
              "id": "pri_01gsz8x8sawmvhz1pv30nge1ke",
              "name": "Monthly (per seat)",
              "type": "standard",
              "status": "active",
              "quantity": {
                "maximum": 999,
                "minimum": 1
              },
              "tax_mode": "account_setting",
              "created_at": "2023-02-23T13:55:22.538367Z",
              "product_id": "pro_01gsz4t5hdjse780zja8vvr7jg",
              "unit_price": {
                "amount": "3000",
                "currency_code": "USD"
              },
              "updated_at": "2024-04-11T13:54:52.254748Z",
              "custom_data": null,
              "description": "Monthly",
              "import_meta": null,
              "trial_period": null,
              "billing_cycle": {
                "interval": "month",
                "frequency": 1
              },
              "unit_price_overrides": []
            },
            "status": "active",
            "product": {
              "id": "pro_01gsz4t5hdjse780zja8vvr7jg",
              "name": "AeroEdit Pro",
              "type": "standard",
              "status": "active",
              "image_url": "https://paddle.s3.amazonaws.com/user/165798/bT1XUOJAQhOUxGs83cbk_pro.png",
              "created_at": "2023-02-23T12:43:46.605Z",
              "updated_at": "2024-04-05T15:53:44.687Z",
              "custom_data": {
                "features": {
                  "sso": false,
                  "route_planning": true,
                  "payment_by_invoice": false,
                  "aircraft_performance": true,
                  "compliance_monitoring": true,
                  "flight_log_management": true
                },
                "suggested_addons": [
                  "pro_01h1vjes1y163xfj1rh1tkfb65",
                  "pro_01gsz97mq9pa4fkyy0wqenepkz"
                ],
                "upgrade_description": "Move from Basic to Pro to take advantage of aircraft performance, advanced route planning, and compliance monitoring."
              },
              "description": "Designed for professional pilots, including all features plus in Basic plus compliance monitoring, route optimization, and third-party integrations.",
              "import_meta": null,
              "tax_category": "standard"
            },
            "quantity": 20,
            "recurring": true,
            "created_at": "2024-04-12T10:38:00.761Z",
            "updated_at": "2024-04-12T10:49:38.76Z",
            "trial_dates": null,
            "next_billed_at": null,
            "previously_billed_at": "2024-04-12T10:37:59.556997Z"
          },
          {
            "price": {
              "id": "pri_01h1vjfevh5etwq3rb416a23h2",
              "name": "Monthly (recurring addon)",
              "type": "standard",
              "status": "active",
              "quantity": {
                "maximum": 100,
                "minimum": 1
              },
              "tax_mode": "account_setting",
              "created_at": "2023-06-01T13:31:12.625056Z",
              "product_id": "pro_01h1vjes1y163xfj1rh1tkfb65",
              "unit_price": {
                "amount": "10000",
                "currency_code": "USD"
              },
              "updated_at": "2024-04-09T07:23:00.907834Z",
              "custom_data": null,
              "description": "Monthly",
              "import_meta": null,
              "trial_period": null,
              "billing_cycle": {
                "interval": "month",
                "frequency": 1
              },
              "unit_price_overrides": []
            },
            "status": "active",
            "product": {
              "id": "pro_01h1vjes1y163xfj1rh1tkfb65",
              "name": "Analytics addon",
              "type": "standard",
              "status": "active",
              "image_url": "https://paddle.s3.amazonaws.com/user/165798/97dRpA6SXzcE6ekK9CAr_analytics.png",
              "created_at": "2023-06-01T13:30:50.302Z",
              "updated_at": "2024-04-05T15:47:17.163Z",
              "custom_data": null,
              "description": "Unlock advanced insights into your flight data with enhanced analytics and reporting features. Includes customizable reporting templates and trend analysis across flights.",
              "import_meta": null,
              "tax_category": "standard"
            },
            "quantity": 1,
            "recurring": true,
            "created_at": "2024-04-12T10:38:00.761Z",
            "updated_at": "2024-04-12T10:38:00.761Z",
            "trial_dates": null,
            "next_billed_at": null,
            "previously_billed_at": "2024-04-12T10:37:59.556997Z"
          },
          {
            "price": {
              "id": "pri_01gsz95g2zrkagg294kpstx54r",
              "name": "Monthly (recurring addon)",
              "type": "standard",
              "status": "active",
              "quantity": {
                "maximum": 1,
                "minimum": 1
              },
              "tax_mode": "account_setting",
              "created_at": "2023-02-23T13:59:52.159927Z",
              "product_id": "pro_01gsz92krfzy3hcx5h5rtgnfwz",
              "unit_price": {
                "amount": "25000",
                "currency_code": "USD"
              },
              "updated_at": "2024-04-09T07:27:48.018296Z",
              "custom_data": null,
              "description": "Monthly (recurring addon)",
              "import_meta": null,
              "trial_period": null,
              "billing_cycle": {
                "interval": "month",
                "frequency": 1
              },
              "unit_price_overrides": []
            },
            "status": "active",
            "product": {
              "id": "pro_01gsz92krfzy3hcx5h5rtgnfwz",
              "name": "VIP support",
              "type": "standard",
              "status": "active",
              "image_url": "https://paddle.s3.amazonaws.com/user/165798/qgyipKJwRtq98YNboipo_vip-support.png",
              "created_at": "2023-02-23T13:58:17.615Z",
              "updated_at": "2024-04-05T15:44:02.893Z",
              "custom_data": null,
              "description": "Get exclusive access to our expert team of product specialists, available to help you make the most of your AeroEdit subscription.",
              "import_meta": null,
              "tax_category": "standard"
            },
            "quantity": 1,
            "recurring": true,
            "created_at": "2024-04-12T10:49:38.765Z",
            "updated_at": "2024-04-12T10:49:38.765Z",
            "trial_dates": null,
            "next_billed_at": null,
            "previously_billed_at": "2024-04-12T10:49:38.765Z"
          }
        ],
        "status": "canceled",
        "discount": null,
        "paused_at": null,
        "address_id": "add_01hv8gq3318ktkfengj2r75gfx",
        "created_at": "2024-04-12T10:38:00.761Z",
        "started_at": "2024-04-12T10:37:59.556997Z",
        "updated_at": "2024-04-12T11:24:54.873Z",
        "business_id": null,
        "canceled_at": "2024-04-12T11:24:54.868Z",
        "custom_data": {
          "organization_id": "#{organization_id}",
          "price_id": "pri_01gsz8x8sawmvhz1pv30nge1ke",
          "product_id": "pro_01h1vjes1y163xfj1rh1tkfb65"
        },
        "customer_id": "ctm_01hv6y1jedq4p1n0yqn5ba3ky4",
        "import_meta": null,
        "billing_cycle": {
          "interval": "month",
          "frequency": 1
        },
        "currency_code": "USD",
        "next_billed_at": null,
        "billing_details": null,
        "collection_mode": "automatic",
        "first_billed_at": "2024-04-12T10:37:59.556997Z",
        "scheduled_change": null,
        "current_billing_period": null
      }
    }
    """
    |> Jason.decode!()
  end

  def webhook_subscription_updated(organization_id) do
    """
    {
      "event_id": "ntfsimevt_01jd01n438b0erzjks9hzjf6d4",
      "event_type": "subscription.updated",
      "occurred_at": "2024-11-18T16:28:23.016853Z",
      "notification_id": "ntfsimntf_01jd01n47myzebyn94egy45z26",
      "data": {
        "id": "sub_01hv8x29kz0t586xy6zn1a62ny",
        "items": [
          {
            "price": {
              "id": "pri_01gsz8x8sawmvhz1pv30nge1ke",
              "name": "Monthly (per seat)",
              "type": "standard",
              "status": "active",
              "quantity": {
                "maximum": 999,
                "minimum": 1
              },
              "tax_mode": "account_setting",
              "created_at": "2023-02-23T13:55:22.538367Z",
              "product_id": "pro_01gsz4t5hdjse780zja8vvr7jg",
              "unit_price": {
                "amount": "3000",
                "currency_code": "USD"
              },
              "updated_at": "2024-04-11T13:54:52.254748Z",
              "custom_data": null,
              "description": "Monthly",
              "import_meta": null,
              "trial_period": null,
              "billing_cycle": {
                "interval": "month",
                "frequency": 1
              },
              "unit_price_overrides": []
            },
            "status": "active",
            "product": {
              "id": "pro_01gsz4t5hdjse780zja8vvr7jg",
              "name": "AeroEdit Pro",
              "type": "standard",
              "status": "active",
              "image_url": "https://paddle.s3.amazonaws.com/user/165798/bT1XUOJAQhOUxGs83cbk_pro.png",
              "created_at": "2023-02-23T12:43:46.605Z",
              "updated_at": "2024-04-05T15:53:44.687Z",
              "custom_data": {
                "features": {
                  "sso": false,
                  "route_planning": true,
                  "payment_by_invoice": false,
                  "aircraft_performance": true,
                  "compliance_monitoring": true,
                  "flight_log_management": true
                },
                "suggested_addons": [
                  "pro_01h1vjes1y163xfj1rh1tkfb65",
                  "pro_01gsz97mq9pa4fkyy0wqenepkz"
                ],
                "upgrade_description": "Move from Basic to Pro to take advantage of aircraft performance, advanced route planning, and compliance monitoring."
              },
              "description": "Designed for professional pilots, including all features plus in Basic plus compliance monitoring, route optimization, and third-party integrations.",
              "import_meta": null,
              "tax_category": "standard"
            },
            "quantity": 20,
            "recurring": true,
            "created_at": "2024-04-12T10:38:00.761Z",
            "updated_at": "2024-04-12T10:49:38.76Z",
            "trial_dates": null,
            "next_billed_at": "2024-05-12T10:37:59.556997Z",
            "previously_billed_at": "2024-04-12T10:37:59.556997Z"
          },
          {
            "price": {
              "id": "pri_01h1vjfevh5etwq3rb416a23h2",
              "name": "Monthly (recurring addon)",
              "type": "standard",
              "status": "active",
              "quantity": {
                "maximum": 100,
                "minimum": 1
              },
              "tax_mode": "account_setting",
              "created_at": "2023-06-01T13:31:12.625056Z",
              "product_id": "pro_01h1vjes1y163xfj1rh1tkfb65",
              "unit_price": {
                "amount": "10000",
                "currency_code": "USD"
              },
              "updated_at": "2024-04-09T07:23:00.907834Z",
              "custom_data": null,
              "description": "Monthly",
              "import_meta": null,
              "trial_period": null,
              "billing_cycle": {
                "interval": "month",
                "frequency": 1
              },
              "unit_price_overrides": []
            },
            "status": "active",
            "product": {
              "id": "pro_01h1vjes1y163xfj1rh1tkfb65",
              "name": "Analytics addon",
              "type": "standard",
              "status": "active",
              "image_url": "https://paddle.s3.amazonaws.com/user/165798/97dRpA6SXzcE6ekK9CAr_analytics.png",
              "created_at": "2023-06-01T13:30:50.302Z",
              "updated_at": "2024-04-05T15:47:17.163Z",
              "custom_data": null,
              "description": "Unlock advanced insights into your flight data with enhanced analytics and reporting features. Includes customizable reporting templates and trend analysis across flights.",
              "import_meta": null,
              "tax_category": "standard"
            },
            "quantity": 1,
            "recurring": true,
            "created_at": "2024-04-12T10:38:00.761Z",
            "updated_at": "2024-04-12T10:38:00.761Z",
            "trial_dates": null,
            "next_billed_at": "2024-05-12T10:37:59.556997Z",
            "previously_billed_at": "2024-04-12T10:37:59.556997Z"
          },
          {
            "price": {
              "id": "pri_01gsz95g2zrkagg294kpstx54r",
              "name": "Monthly (recurring addon)",
              "type": "standard",
              "status": "active",
              "quantity": {
                "maximum": 1,
                "minimum": 1
              },
              "tax_mode": "account_setting",
              "created_at": "2023-02-23T13:59:52.159927Z",
              "product_id": "pro_01gsz92krfzy3hcx5h5rtgnfwz",
              "unit_price": {
                "amount": "25000",
                "currency_code": "USD"
              },
              "updated_at": "2024-04-09T07:27:48.018296Z",
              "custom_data": null,
              "description": "Monthly (recurring addon)",
              "import_meta": null,
              "trial_period": null,
              "billing_cycle": {
                "interval": "month",
                "frequency": 1
              },
              "unit_price_overrides": []
            },
            "status": "active",
            "product": {
              "id": "pro_01gsz92krfzy3hcx5h5rtgnfwz",
              "name": "VIP support",
              "type": "standard",
              "status": "active",
              "image_url": "https://paddle.s3.amazonaws.com/user/165798/qgyipKJwRtq98YNboipo_vip-support.png",
              "created_at": "2023-02-23T13:58:17.615Z",
              "updated_at": "2024-04-05T15:44:02.893Z",
              "custom_data": null,
              "description": "Get exclusive access to our expert team of product specialists, available to help you make the most of your AeroEdit subscription.",
              "import_meta": null,
              "tax_category": "standard"
            },
            "quantity": 1,
            "recurring": true,
            "created_at": "2024-04-12T10:49:38.765Z",
            "updated_at": "2024-04-12T10:49:38.765Z",
            "trial_dates": null,
            "next_billed_at": "2024-05-12T10:37:59.556997Z",
            "previously_billed_at": "2024-04-12T10:49:38.765Z"
          }
        ],
        "status": "active",
        "discount": null,
        "paused_at": null,
        "address_id": "add_01hv8gq3318ktkfengj2r75gfx",
        "created_at": "2024-04-12T10:38:00.761Z",
        "started_at": "2024-04-12T10:37:59.556997Z",
        "updated_at": "2024-04-12T10:49:38.771Z",
        "business_id": null,
        "canceled_at": null,
        "custom_data": {
          "organization_id": "#{organization_id}",
          "price_id": "pri_01gsz8x8sawmvhz1pv30nge1ke",
          "product_id": "pro_01gsz4t5hdjse780zja8vvr7jg"
        },
        "customer_id": "ctm_01hv6y1jedq4p1n0yqn5ba3ky4",
        "import_meta": null,
        "billing_cycle": {
          "interval": "month",
          "frequency": 1
        },
        "currency_code": "USD",
        "next_billed_at": "2024-05-12T10:37:59.556997Z",
        "billing_details": null,
        "collection_mode": "automatic",
        "first_billed_at": "2024-04-12T10:37:59.556997Z",
        "scheduled_change": null,
        "current_billing_period": {
          "ends_at": "2024-05-12T10:37:59.556997Z",
          "starts_at": "2024-04-12T10:37:59.556997Z"
        }
      }
    }
    """
    |> Jason.decode!()
  end

  def webhook_subscription_updated_intent_to_cancel(organization_id) do
    """
    {
      "event_id": "ntfsimevt_01jd01n438b0erzjks9hzjf6d4",
      "event_type": "subscription.updated",
      "occurred_at": "2024-11-18T16:28:23.016853Z",
      "notification_id": "ntfsimntf_01jd01n47myzebyn94egy45z26",
      "data": {
        "id": "sub_01hv8x29kz0t586xy6zn1a62ny",
        "items": [
          {
            "price": {
              "id": "pri_01gsz8x8sawmvhz1pv30nge1ke",
              "name": "Monthly (per seat)",
              "type": "standard",
              "status": "active",
              "quantity": {
                "maximum": 999,
                "minimum": 1
              },
              "tax_mode": "account_setting",
              "created_at": "2023-02-23T13:55:22.538367Z",
              "product_id": "pro_01gsz4t5hdjse780zja8vvr7jg",
              "unit_price": {
                "amount": "3000",
                "currency_code": "USD"
              },
              "updated_at": "2024-04-11T13:54:52.254748Z",
              "custom_data": null,
              "description": "Monthly",
              "import_meta": null,
              "trial_period": null,
              "billing_cycle": {
                "interval": "month",
                "frequency": 1
              },
              "unit_price_overrides": []
            },
            "status": "active",
            "product": {
              "id": "pro_01gsz4t5hdjse780zja8vvr7jg",
              "name": "AeroEdit Pro",
              "type": "standard",
              "status": "active",
              "image_url": "https://paddle.s3.amazonaws.com/user/165798/bT1XUOJAQhOUxGs83cbk_pro.png",
              "created_at": "2023-02-23T12:43:46.605Z",
              "updated_at": "2024-04-05T15:53:44.687Z",
              "custom_data": {
                "features": {
                  "sso": false,
                  "route_planning": true,
                  "payment_by_invoice": false,
                  "aircraft_performance": true,
                  "compliance_monitoring": true,
                  "flight_log_management": true
                },
                "suggested_addons": [
                  "pro_01h1vjes1y163xfj1rh1tkfb65",
                  "pro_01gsz97mq9pa4fkyy0wqenepkz"
                ],
                "upgrade_description": "Move from Basic to Pro to take advantage of aircraft performance, advanced route planning, and compliance monitoring."
              },
              "description": "Designed for professional pilots, including all features plus in Basic plus compliance monitoring, route optimization, and third-party integrations.",
              "import_meta": null,
              "tax_category": "standard"
            },
            "quantity": 20,
            "recurring": true,
            "created_at": "2024-04-12T10:38:00.761Z",
            "updated_at": "2024-04-12T10:49:38.76Z",
            "trial_dates": null,
            "next_billed_at": "2024-05-12T10:37:59.556997Z",
            "previously_billed_at": "2024-04-12T10:37:59.556997Z"
          },
          {
            "price": {
              "id": "pri_01h1vjfevh5etwq3rb416a23h2",
              "name": "Monthly (recurring addon)",
              "type": "standard",
              "status": "active",
              "quantity": {
                "maximum": 100,
                "minimum": 1
              },
              "tax_mode": "account_setting",
              "created_at": "2023-06-01T13:31:12.625056Z",
              "product_id": "pro_01h1vjes1y163xfj1rh1tkfb65",
              "unit_price": {
                "amount": "10000",
                "currency_code": "USD"
              },
              "updated_at": "2024-04-09T07:23:00.907834Z",
              "custom_data": null,
              "description": "Monthly",
              "import_meta": null,
              "trial_period": null,
              "billing_cycle": {
                "interval": "month",
                "frequency": 1
              },
              "unit_price_overrides": []
            },
            "status": "active",
            "product": {
              "id": "pro_01h1vjes1y163xfj1rh1tkfb65",
              "name": "Analytics addon",
              "type": "standard",
              "status": "active",
              "image_url": "https://paddle.s3.amazonaws.com/user/165798/97dRpA6SXzcE6ekK9CAr_analytics.png",
              "created_at": "2023-06-01T13:30:50.302Z",
              "updated_at": "2024-04-05T15:47:17.163Z",
              "custom_data": null,
              "description": "Unlock advanced insights into your flight data with enhanced analytics and reporting features. Includes customizable reporting templates and trend analysis across flights.",
              "import_meta": null,
              "tax_category": "standard"
            },
            "quantity": 1,
            "recurring": true,
            "created_at": "2024-04-12T10:38:00.761Z",
            "updated_at": "2024-04-12T10:38:00.761Z",
            "trial_dates": null,
            "next_billed_at": "2024-05-12T10:37:59.556997Z",
            "previously_billed_at": "2024-04-12T10:37:59.556997Z"
          },
          {
            "price": {
              "id": "pri_01gsz95g2zrkagg294kpstx54r",
              "name": "Monthly (recurring addon)",
              "type": "standard",
              "status": "active",
              "quantity": {
                "maximum": 1,
                "minimum": 1
              },
              "tax_mode": "account_setting",
              "created_at": "2023-02-23T13:59:52.159927Z",
              "product_id": "pro_01gsz92krfzy3hcx5h5rtgnfwz",
              "unit_price": {
                "amount": "25000",
                "currency_code": "USD"
              },
              "updated_at": "2024-04-09T07:27:48.018296Z",
              "custom_data": null,
              "description": "Monthly (recurring addon)",
              "import_meta": null,
              "trial_period": null,
              "billing_cycle": {
                "interval": "month",
                "frequency": 1
              },
              "unit_price_overrides": []
            },
            "status": "active",
            "product": {
              "id": "pro_01gsz92krfzy3hcx5h5rtgnfwz",
              "name": "VIP support",
              "type": "standard",
              "status": "active",
              "image_url": "https://paddle.s3.amazonaws.com/user/165798/qgyipKJwRtq98YNboipo_vip-support.png",
              "created_at": "2023-02-23T13:58:17.615Z",
              "updated_at": "2024-04-05T15:44:02.893Z",
              "custom_data": null,
              "description": "Get exclusive access to our expert team of product specialists, available to help you make the most of your AeroEdit subscription.",
              "import_meta": null,
              "tax_category": "standard"
            },
            "quantity": 1,
            "recurring": true,
            "created_at": "2024-04-12T10:49:38.765Z",
            "updated_at": "2024-04-12T10:49:38.765Z",
            "trial_dates": null,
            "next_billed_at": "2024-05-12T10:37:59.556997Z",
            "previously_billed_at": "2024-04-12T10:49:38.765Z"
          }
        ],
        "status": "active",
        "discount": null,
        "paused_at": null,
        "address_id": "add_01hv8gq3318ktkfengj2r75gfx",
        "created_at": "2024-04-12T10:38:00.761Z",
        "started_at": "2024-04-12T10:37:59.556997Z",
        "updated_at": "2024-04-12T10:49:38.771Z",
        "business_id": null,
        "canceled_at": null,
        "custom_data": {
          "organization_id": "#{organization_id}",
          "price_id": "pri_01gsz8x8sawmvhz1pv30nge1ke",
          "product_id": "pro_01gsz4t5hdjse780zja8vvr7jg"
        },
        "customer_id": "ctm_01hv6y1jedq4p1n0yqn5ba3ky4",
        "import_meta": null,
        "billing_cycle": {
          "interval": "month",
          "frequency": 1
        },
        "currency_code": "USD",
        "next_billed_at": "2024-05-12T10:37:59.556997Z",
        "billing_details": null,
        "collection_mode": "automatic",
        "first_billed_at": "2024-04-12T10:37:59.556997Z",
        "scheduled_change": {
          "action": "cancel",
          "effective_at": "2024-03-12T10:37:59.556997Z",
          "resume_at": null
        },
        "current_billing_period": {
          "ends_at": "2024-05-12T10:37:59.556997Z",
          "starts_at": "2024-04-12T10:37:59.556997Z"
        }
      }
    }
    """
    |> Jason.decode!()
  end

  def webhook_subscription_updated_intent_to_pause(organization_id) do
    """
    {
      "event_id": "ntfsimevt_01jd01n438b0erzjks9hzjf6d4",
      "event_type": "subscription.updated",
      "occurred_at": "2024-11-18T16:28:23.016853Z",
      "notification_id": "ntfsimntf_01jd01n47myzebyn94egy45z26",
      "data": {
        "id": "sub_01hv8x29kz0t586xy6zn1a62ny",
        "items": [
          {
            "price": {
              "id": "pri_01gsz8x8sawmvhz1pv30nge1ke",
              "name": "Monthly (per seat)",
              "type": "standard",
              "status": "active",
              "quantity": {
                "maximum": 999,
                "minimum": 1
              },
              "tax_mode": "account_setting",
              "created_at": "2023-02-23T13:55:22.538367Z",
              "product_id": "pro_01gsz4t5hdjse780zja8vvr7jg",
              "unit_price": {
                "amount": "3000",
                "currency_code": "USD"
              },
              "updated_at": "2024-04-11T13:54:52.254748Z",
              "custom_data": null,
              "description": "Monthly",
              "import_meta": null,
              "trial_period": null,
              "billing_cycle": {
                "interval": "month",
                "frequency": 1
              },
              "unit_price_overrides": []
            },
            "status": "active",
            "product": {
              "id": "pro_01gsz4t5hdjse780zja8vvr7jg",
              "name": "AeroEdit Pro",
              "type": "standard",
              "status": "active",
              "image_url": "https://paddle.s3.amazonaws.com/user/165798/bT1XUOJAQhOUxGs83cbk_pro.png",
              "created_at": "2023-02-23T12:43:46.605Z",
              "updated_at": "2024-04-05T15:53:44.687Z",
              "custom_data": {
                "features": {
                  "sso": false,
                  "route_planning": true,
                  "payment_by_invoice": false,
                  "aircraft_performance": true,
                  "compliance_monitoring": true,
                  "flight_log_management": true
                },
                "suggested_addons": [
                  "pro_01h1vjes1y163xfj1rh1tkfb65",
                  "pro_01gsz97mq9pa4fkyy0wqenepkz"
                ],
                "upgrade_description": "Move from Basic to Pro to take advantage of aircraft performance, advanced route planning, and compliance monitoring."
              },
              "description": "Designed for professional pilots, including all features plus in Basic plus compliance monitoring, route optimization, and third-party integrations.",
              "import_meta": null,
              "tax_category": "standard"
            },
            "quantity": 20,
            "recurring": true,
            "created_at": "2024-04-12T10:38:00.761Z",
            "updated_at": "2024-04-12T10:49:38.76Z",
            "trial_dates": null,
            "next_billed_at": "2024-05-12T10:37:59.556997Z",
            "previously_billed_at": "2024-04-12T10:37:59.556997Z"
          },
          {
            "price": {
              "id": "pri_01h1vjfevh5etwq3rb416a23h2",
              "name": "Monthly (recurring addon)",
              "type": "standard",
              "status": "active",
              "quantity": {
                "maximum": 100,
                "minimum": 1
              },
              "tax_mode": "account_setting",
              "created_at": "2023-06-01T13:31:12.625056Z",
              "product_id": "pro_01h1vjes1y163xfj1rh1tkfb65",
              "unit_price": {
                "amount": "10000",
                "currency_code": "USD"
              },
              "updated_at": "2024-04-09T07:23:00.907834Z",
              "custom_data": null,
              "description": "Monthly",
              "import_meta": null,
              "trial_period": null,
              "billing_cycle": {
                "interval": "month",
                "frequency": 1
              },
              "unit_price_overrides": []
            },
            "status": "active",
            "product": {
              "id": "pro_01h1vjes1y163xfj1rh1tkfb65",
              "name": "Analytics addon",
              "type": "standard",
              "status": "active",
              "image_url": "https://paddle.s3.amazonaws.com/user/165798/97dRpA6SXzcE6ekK9CAr_analytics.png",
              "created_at": "2023-06-01T13:30:50.302Z",
              "updated_at": "2024-04-05T15:47:17.163Z",
              "custom_data": null,
              "description": "Unlock advanced insights into your flight data with enhanced analytics and reporting features. Includes customizable reporting templates and trend analysis across flights.",
              "import_meta": null,
              "tax_category": "standard"
            },
            "quantity": 1,
            "recurring": true,
            "created_at": "2024-04-12T10:38:00.761Z",
            "updated_at": "2024-04-12T10:38:00.761Z",
            "trial_dates": null,
            "next_billed_at": "2024-05-12T10:37:59.556997Z",
            "previously_billed_at": "2024-04-12T10:37:59.556997Z"
          },
          {
            "price": {
              "id": "pri_01gsz95g2zrkagg294kpstx54r",
              "name": "Monthly (recurring addon)",
              "type": "standard",
              "status": "active",
              "quantity": {
                "maximum": 1,
                "minimum": 1
              },
              "tax_mode": "account_setting",
              "created_at": "2023-02-23T13:59:52.159927Z",
              "product_id": "pro_01gsz92krfzy3hcx5h5rtgnfwz",
              "unit_price": {
                "amount": "25000",
                "currency_code": "USD"
              },
              "updated_at": "2024-04-09T07:27:48.018296Z",
              "custom_data": null,
              "description": "Monthly (recurring addon)",
              "import_meta": null,
              "trial_period": null,
              "billing_cycle": {
                "interval": "month",
                "frequency": 1
              },
              "unit_price_overrides": []
            },
            "status": "active",
            "product": {
              "id": "pro_01gsz92krfzy3hcx5h5rtgnfwz",
              "name": "VIP support",
              "type": "standard",
              "status": "active",
              "image_url": "https://paddle.s3.amazonaws.com/user/165798/qgyipKJwRtq98YNboipo_vip-support.png",
              "created_at": "2023-02-23T13:58:17.615Z",
              "updated_at": "2024-04-05T15:44:02.893Z",
              "custom_data": null,
              "description": "Get exclusive access to our expert team of product specialists, available to help you make the most of your AeroEdit subscription.",
              "import_meta": null,
              "tax_category": "standard"
            },
            "quantity": 1,
            "recurring": true,
            "created_at": "2024-04-12T10:49:38.765Z",
            "updated_at": "2024-04-12T10:49:38.765Z",
            "trial_dates": null,
            "next_billed_at": "2024-05-12T10:37:59.556997Z",
            "previously_billed_at": "2024-04-12T10:49:38.765Z"
          }
        ],
        "status": "active",
        "discount": null,
        "paused_at": null,
        "address_id": "add_01hv8gq3318ktkfengj2r75gfx",
        "created_at": "2024-04-12T10:38:00.761Z",
        "started_at": "2024-04-12T10:37:59.556997Z",
        "updated_at": "2024-04-12T10:49:38.771Z",
        "business_id": null,
        "canceled_at": null,
        "custom_data": {
          "organization_id": "#{organization_id}",
          "price_id": "pri_01h1vjfevh5etwq3rb416a23h2",
          "product_id": "pro_01gsz4t5hdjse780zja8vvr7jg"
        },
        "customer_id": "ctm_01hv6y1jedq4p1n0yqn5ba3ky4",
        "import_meta": null,
        "billing_cycle": {
          "interval": "month",
          "frequency": 1
        },
        "currency_code": "USD",
        "next_billed_at": "2024-05-12T10:37:59.556997Z",
        "billing_details": null,
        "collection_mode": "automatic",
        "first_billed_at": "2024-04-12T10:37:59.556997Z",
        "scheduled_change": {
          "action": "pause",
          "effective_at": "2024-03-12T10:37:59.556997Z",
          "resume_at": null
        },
        "current_billing_period": {
          "ends_at": "2024-05-12T10:37:59.556997Z",
          "starts_at": "2024-04-12T10:37:59.556997Z"
        }
      }
    }
    """
    |> Jason.decode!()
  end

  def webhook_subscription_paused(organization_id) do
    """
    {
      "event_id": "ntfsimevt_01jdbjtbmvswwmn1ey2nydzvve",
      "event_type": "subscription.paused",
      "occurred_at": "2024-11-23T03:59:59.131821Z",
      "notification_id": "ntfsimntf_01jdbjtbr8ya0b7fxzwfk5h2x8",
      "data": {
        "id": "sub_01hv8x29kz0t586xy6zn1a62ny",
        "items": [
          {
            "price": {
              "id": "pri_01gsz8x8sawmvhz1pv30nge1ke",
              "name": "Monthly (per seat)",
              "type": "standard",
              "status": "active",
              "quantity": {
                "maximum": 999,
                "minimum": 1
              },
              "tax_mode": "account_setting",
              "created_at": "2023-02-23T13:55:22.538367Z",
              "product_id": "pro_01gsz4t5hdjse780zja8vvr7jg",
              "unit_price": {
                "amount": "3000",
                "currency_code": "USD"
              },
              "updated_at": "2024-04-11T13:54:52.254748Z",
              "custom_data": null,
              "description": "Monthly",
              "import_meta": null,
              "trial_period": null,
              "billing_cycle": {
                "interval": "month",
                "frequency": 1
              },
              "unit_price_overrides": []
            },
            "status": "active",
            "product": {
              "id": "pro_01gsz4t5hdjse780zja8vvr7jg",
              "name": "AeroEdit Pro",
              "type": "standard",
              "status": "active",
              "image_url": "https://paddle.s3.amazonaws.com/user/165798/bT1XUOJAQhOUxGs83cbk_pro.png",
              "created_at": "2023-02-23T12:43:46.605Z",
              "updated_at": "2024-04-05T15:53:44.687Z",
              "custom_data": {
                "features": {
                  "sso": false,
                  "route_planning": true,
                  "payment_by_invoice": false,
                  "aircraft_performance": true,
                  "compliance_monitoring": true,
                  "flight_log_management": true
                },
                "suggested_addons": [
                  "pro_01h1vjes1y163xfj1rh1tkfb65",
                  "pro_01gsz97mq9pa4fkyy0wqenepkz"
                ],
                "upgrade_description": "Move from Basic to Pro to take advantage of aircraft performance, advanced route planning, and compliance monitoring."
              },
              "description": "Designed for professional pilots, including all features plus in Basic plus compliance monitoring, route optimization, and third-party integrations.",
              "import_meta": null,
              "tax_category": "standard"
            },
            "quantity": 10,
            "recurring": true,
            "created_at": "2024-04-12T12:42:27.89Z",
            "updated_at": "2024-04-12T12:42:27.89Z",
            "trial_dates": null,
            "next_billed_at": null,
            "previously_billed_at": "2024-04-12T12:42:27.185672Z"
          },
          {
            "price": {
              "id": "pri_01h1vjfevh5etwq3rb416a23h2",
              "name": "Monthly (recurring addon)",
              "type": "standard",
              "status": "active",
              "quantity": {
                "maximum": 100,
                "minimum": 1
              },
              "tax_mode": "account_setting",
              "created_at": "2023-06-01T13:31:12.625056Z",
              "product_id": "pro_01h1vjes1y163xfj1rh1tkfb65",
              "unit_price": {
                "amount": "10000",
                "currency_code": "USD"
              },
              "updated_at": "2024-04-12T10:42:45.476453Z",
              "custom_data": null,
              "description": "Monthly",
              "import_meta": null,
              "trial_period": null,
              "billing_cycle": {
                "interval": "month",
                "frequency": 1
              },
              "unit_price_overrides": []
            },
            "status": "active",
            "product": {
              "id": "pro_01h1vjes1y163xfj1rh1tkfb65",
              "name": "Analytics addon",
              "type": "standard",
              "status": "active",
              "image_url": "https://paddle.s3.amazonaws.com/user/165798/97dRpA6SXzcE6ekK9CAr_analytics.png",
              "created_at": "2023-06-01T13:30:50.302Z",
              "updated_at": "2024-04-05T15:47:17.163Z",
              "custom_data": null,
              "description": "Unlock advanced insights into your flight data with enhanced analytics and reporting features. Includes customizable reporting templates and trend analysis across flights.",
              "import_meta": null,
              "tax_category": "standard"
            },
            "quantity": 1,
            "recurring": true,
            "created_at": "2024-04-12T12:42:27.89Z",
            "updated_at": "2024-04-12T12:42:27.89Z",
            "trial_dates": null,
            "next_billed_at": null,
            "previously_billed_at": "2024-04-12T12:42:27.185672Z"
          }
        ],
        "status": "paused",
        "discount": null,
        "paused_at": "2024-04-12T12:43:43.214Z",
        "address_id": "add_01hv8gq3318ktkfengj2r75gfx",
        "created_at": "2024-04-12T12:42:27.89Z",
        "started_at": "2024-04-12T12:42:27.185672Z",
        "updated_at": "2024-04-12T12:43:43.219Z",
        "business_id": null,
        "canceled_at": null,
        "custom_data": {
          "organization_id": "#{organization_id}",
          "price_id": "pri_01gsz8x8sawmvhz1pv30nge1ke",
          "product_id": "pro_01gsz4t5hdjse780zja8vvr7jg"
        },
        "customer_id": "ctm_01hv6y1jedq4p1n0yqn5ba3ky4",
        "import_meta": null,
        "billing_cycle": {
          "interval": "month",
          "frequency": 1
        },
        "currency_code": "USD",
        "next_billed_at": null,
        "billing_details": null,
        "collection_mode": "automatic",
        "first_billed_at": "2024-04-12T12:42:27.185672Z",
        "scheduled_change": null,
        "current_billing_period": null
      }
    }
    """
    |> Jason.decode!()
  end
end
