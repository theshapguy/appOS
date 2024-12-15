defmodule Planet.PaddleClassicHandlerTest do
  use Planet.DataCase

  import Planet.AccountsFixtures

  alias Planet.Payments.PaddleClassicHandler
  alias Planet.Subscriptions.Subscription

  describe "paddle webhook handler" do
    setup do
      %{subscription: user_fixture().organization.subscription}
    end

    test "subscription_payment_succeeded", %{subscription: s} do
      {:ok, %Subscription{} = subscription} =
        PaddleClassicHandler.handler(
          %{
            assigns: %{paddle_passthrough: %{"organization_id" => s.organization_id}}
          },
          %{
            "alert_id" => "727032462",
            "fee" => "0.62",
            "marketing_consent" => "1",
            "event_time" => "2023-07-08 01:00:10",
            "status" => "active",
            "passthrough" => "organization_id;gKg12n;user_id;gKg12n",
            "quantity" => "29",
            "plan_name" => "Example String",
            "custom_data" => "custom_data",
            "instalments" => "9",
            "p_signature" =>
              "cbJ9m0BuIJujHJYkSPq3eBMBcO04hFwcmoKUAAQAuELixtHPrJm4YmxPD8ei+o/zdvr1wEqnWPTC0opkM3M6yUBVhV/DkBmvnnXRBHIbc6LhU9hXg+ihYmJ/dKQgsiIM19YovdYxod0tWYTjFFGyP/11BPDaZ4yan8VQg4bb62pRp7/J6JjQqLQyCrDC8BTX43W5mvya77osES0zjwCROWcK/udyL0+CV8rvmWoYj47WUGQGGeyOfYfaReCGD7KGsvzTd1PIFrqSzxKcaeXf45wjFHdYzUogbJav0k5yx0vr0kyqYlKwWEKulwuN94JE61KX8jpCBL7LjdSynVaWZSJ+XFBsQU5z1oY85X3DWNmlkalcb6kbgESbhvx/iWEKYLxvPljxxVY8PcbV39cZqeIQJDTefm8gol5ptwro1lQFPw9tsrv85G6+fZKKTpJAH6/WR0COj2+nGBI8gTCw30nHZ02u0XH9lGKqmzl4MZ6KEXmg5/9cFEf3vWYXNAgp0apnPAXho+fDaRO3AN619fBsBbfo/PDUKgrFxHb2CSbXYR/yEeYImLwdYEmfBbCvwUeP4GOMA58ifbEPy4d4XWudKNgCHvRus3/XEhr4sSYzHRy5l+xAA+Wlx6nOeTd9EipK8n6laD/25LMpSC5xeG1DQZboEAt2pMUBRrZV2ZQ=",
            "sale_gross" => "121.86",
            "earnings" => "494.3",
            "balance_fee" => "954.35",
            "checkout_id" => "6-00b9ae6747797ed-df73ac399e",
            "currency" => "GBP",
            "next_payment_amount" => "next_payment_amount",
            "unit_price" => "unit_price",
            "balance_currency" => "GBP",
            "balance_gross" => "345.39",
            "initial_payment" => "false",
            "alert_name" => "subscription_payment_succeeded",
            "balance_tax" => "279.54",
            "user_id" => "5",
            "country" => "DE",
            "next_bill_date" => "2023-07-11",
            "order_id" => "2",
            "email" => "steuber.pat@example.com",
            "coupon" => "Coupon 6",
            "balance_earnings" => "677.86",
            "customer_name" => "customer_name",
            "subscription_plan_id" => "901",
            "subscription_id" => "9",
            "subscription_payment_id" => "5",
            "payment_method" => "paypal",
            "payment_tax" => "0.56",
            "receipt_url" => "https://sandbox-my.paddle.com/receipt/6/2535d20d86c1916-0719b350b1"
          }
        )

      assert subscription.status == :active
      assert subscription.issued_at == ~U[2023-07-08 01:00:10Z]
      assert subscription.valid_until == ~U[2023-07-11 00:00:00Z]
      assert subscription.customer_id == "5"
      assert subscription.subscription_id == "9"
      assert subscription.payment_attempt == nil
      assert subscription.product_id == "901"
    end

    test "subscription_created", %{subscription: s} do
      {:ok, %Subscription{} = subscription} =
        PaddleClassicHandler.handler(
          %{
            assigns: %{paddle_passthrough: %{"organization_id" => s.organization_id}}
          },
          %{
            "alert_id" => "183732876",
            "alert_name" => "subscription_created",
            "cancel_url" =>
              "https://sandbox-checkout.paddle.com/subscription/cancel?user=4&subscription=8&hash=267a385fc4eb0b219378676466c31b8c13d51492",
            "checkout_id" => "4-eb9a28ebb4c1c1f-abc853a008",
            "currency" => "EUR",
            "custom_data" => "custom_data",
            "email" => "hilario.waters@example.com",
            "event_time" => "2023-07-08 01:13:19",
            "linked_subscriptions" => "4, 8, 8",
            "marketing_consent" => "",
            "next_bill_date" => "2023-09-01",
            "p_signature" =>
              "gn0WaH3OBBCL39Wom7MgEK+5TaOPFQ8ZWax7jSxz0obpPb+y69ffE859Ucz6e2tdVm6h4dvH1rhnLHfg1PK+M12cTb/TOQ1j+OWEDqav7yiIHGdJItXRInJUMHd1iNpIoVRQ3/9NV05lUVIrakvJJiTTdVW1AaV8to2mkJ1hftpcdu6w4cFsotu5FKuE2hiTivRcmHxzOBFO1d3INn7EsSwHBT1LoZQglK160Polh3366C7tjM5eNabcxkOP2qsKwVSC7IaRfuKsC4o/DaXXOAQs5YaOvwdwi4QNHS3CfHMgLQ8tT3yhYNdPmXCTQDS0D2hcW9YfAOlGDewf/fYNUIIm5FS45GpflvclNMeEeG1BlT1ucMLWR2gziy0xhMV8cA9ipTu1MXcLTrB07+gVhwpTQAoBQaow8qGPaRNNG+7Wfz16fvGcZ1eSk7AMEGNrOtTzd4P19rbtOIKGAKqhYaxekYmlHIEzbVbXSk8BVpyrBQaumUKle+MgN3Ve6phR4adgARef8TRWDSue5+ZcWQCWzF72osLehD2x3IA6f//z+VJ/G3dEOzA9Ze9uZZNApdORDJ6MdzJ1SxBt2gc1ub8tDWFo/uKq1pwg5Yeo//+CgCz2XQfUXlT86kH2PCETOj2P+4rVyBw81j7eYH9VVG4PqdkPac9Q/pcrYOjqobs=",
            "passthrough" => "organization_id;gKg12n;user_id;gKg12n",
            "quantity" => "94",
            "source" => "Import",
            "status" => "active",
            "subscription_id" => "8",
            "subscription_plan_id" => "201",
            "unit_price" => "unit_price",
            "update_url" =>
              "https://sandbox-checkout.paddle.com/subscription/update?user=1&subscription=7&hash=a42322a2ebb8182f1cf04175423397f406c2b66d",
            "user_id" => "3"
          }
        )

      assert subscription.status == :active

      assert subscription.issued_at == ~U[2023-07-08 01:13:19Z]
      assert subscription.valid_until == ~U[2023-09-01 00:00:00Z]
      assert subscription.customer_id == "3"
      assert subscription.subscription_id == "8"
      assert subscription.payment_attempt == nil
      assert subscription.product_id == "201"

      assert subscription.update_url ==
               "https://sandbox-checkout.paddle.com/subscription/update?user=1&subscription=7&hash=a42322a2ebb8182f1cf04175423397f406c2b66d"

      assert subscription.cancel_url ==
               "https://sandbox-checkout.paddle.com/subscription/cancel?user=4&subscription=8&hash=267a385fc4eb0b219378676466c31b8c13d51492"
    end

    test "subscription_cancelled", %{subscription: s} do
      {:ok, %Subscription{} = subscription} =
        PaddleClassicHandler.handler(
          %{
            assigns: %{paddle_passthrough: %{"organization_id" => s.organization_id}}
          },
          %{
            "alert_id" => "852822538",
            "alert_name" => "subscription_cancelled",
            "cancellation_effective_date" => "2023-07-19",
            "checkout_id" => "1-3b55236eb2f61cb-44f1fb7721",
            "currency" => "EUR",
            "custom_data" => "custom_data",
            "email" => "monserrate.crona@example.net",
            "event_time" => "2023-07-08 01:18:44",
            "linked_subscriptions" => "9, 9, 7",
            "marketing_consent" => "1",
            "p_signature" =>
              "h1NiBvDBkzRH2JGh1cTIgq57z2Dnsobn4XQTgKqCGFDYdhKEjjGtk39h98uIcPgQDUXPF8UQE8Syq5Lm86orlziMsiqXJQkP2BzLuWXucOYYACj8vkRsPb2lnWgo/wvf6qM3ciuzgUhFutFFt3F9dW09dmrvjR21jooPiZJLuJXT0agsjfbIGoXP0F7/+JPW+Di5+mE3tutXORZhdqEcWbzandmuYk0GjSemM/TH4jUY7M7REAxgj2pRxoONExZnjRyR8rCvOHrauOR8vKPHAHyhkG/wA8r47PL/uPPW2CUE69IfkWOFdqmtRh6Hy4kKu3IkgLaYSQh/wERUEuBezvokvlTmg2SVVy9zOCUKJ7U56HwA9LcK9S8+NYUwGUuvQdRLnrgHvTAZYOWc5KC9NhI3sp6h3aCmzRHBsJKjvO337LQ597TkqWe4iQEUdnKKbRMpmOtt9VqAN+Nvp87pST+4iDV8UWQ1GNF7dmPBOOKoLa9o0J35KzZU8U7uLhyVEFfzGB90k7DHTWKxXY+nTI8eCBatf4jIAwsCai3rHI1JSFbe4c4iwXCj/RjMEOyHwUQvNwqV0eoCLYrFJHy/w+fmwksamZk6/pdt7Q164gfVesafPYLNA1UeZgB7fO7ndpa4Lixc6ZGIp3ZEjB5NrZQ+7mfLHArx0uL209W4uiw=",
            "passthrough" => "organization_id;gKg12n;user_id;gKg12n",
            "quantity" => "20",
            "status" => "deleted",
            "subscription_id" => "1",
            "subscription_plan_id" => "8",
            "unit_price" => "unit_price",
            "user_id" => "5"
          }
        )

      # Through Free Plan
      assert subscription.status == :unpaid

      assert subscription.issued_at == ~U[2023-07-08 01:18:44Z]
      assert subscription.valid_until == ~U[2023-07-19 00:00:00Z]
      assert subscription.customer_id == "5"
      assert subscription.subscription_id == nil
      assert subscription.payment_attempt == nil
      assert subscription.product_id == "default"

      assert subscription.update_url == nil
      assert subscription.cancel_url == nil
    end

    test "subscription_payment_failed", %{subscription: s} do
      {:ok, %Subscription{} = subscription} =
        PaddleClassicHandler.handler(
          %{
            assigns: %{paddle_passthrough: %{"organization_id" => s.organization_id}}
          },
          %{
            "alert_id" => "288059511",
            "alert_name" => "subscription_payment_failed",
            "amount" => "178.25",
            "attempt_number" => "attempt_number",
            "cancel_url" =>
              "https://sandbox-checkout.paddle.com/subscription/cancel?user=4&subscription=3&hash=ea821d03db4ebbd6b30512a7f5992c34d8c3ee67",
            "checkout_id" => "2-9f28157cef47032-714c8a09b7",
            "currency" => "USD",
            "custom_data" => "custom_data",
            "email" => "wolf.may@example.org",
            "event_time" => "2023-07-08 01:22:56",
            "instalments" => "6",
            "marketing_consent" => "1",
            "next_retry_date" => "2023-07-30",
            "order_id" => "4",
            "p_signature" =>
              "G7ksSruImrdn35C62DAcxvczZrY38ZJoW3mtGDhbMfLbYyenzlX2/98qBE1wwx03LWrGu+dme1KDyEntmiuk/GHFpuDHGr/zzoUIbdCArs8uJ7euwyVcGDDYo7fv9GZWP47o1AfpTMLWaIx0ISI3nsII4hL8ymSVneKSx6Nzaii2xbw46Q0ZEWZIx6lh59X5t+tJkoj5OVLwngaV5cb9ATMKIcjDRuDjGKbPdSfn/K1tEg+IPCachYgIwsjprdkHOHQ6loppovwXV8kDx3gNTKaq8T8Ne+LC6C/8T247NDTo1kvZXM1pswxjYNfg62PNFusln2T4W7qtPsG1Uv8gdzyX5is8WAOpPyE4041zgjsvVL4VWccYKJF1ZUeq5YRKq3JUPgAfJkVkW82KF0yyHx2RV7YXTXcv8+30U+a3TinMM1IEg9WWi7WVEbZe4hXjLoyyYTJ31fbM2MvoyvtV6Ksfjmj5OCjHiwlIU4mVjcsQfAqXcHW+ICoonh5dsx4IW1ZaktYlMBRRTnS5upy/BFbCAJNzowtM8sjwZkb2lJep/OTG/ixFxzpHRdzpYL/XWwJP8UmjJeL8wgYRF+Lp9xcQsASuYMmp+xAMlUDCQcwok2BfiKumkB5zra/ALtUS7uDvCgi36oyUs4JJTMk9sJPt5hEDY7PpMDURHhwdKN0=",
            "passthrough" => "organization_id;gKg12n;user_id;gKg12n",
            "quantity" => "92",
            "status" => "active",
            "subscription_id" => "1",
            "subscription_payment_id" => "2",
            "subscription_plan_id" => "2",
            "unit_price" => "unit_price",
            "update_url" =>
              "https://sandbox-checkout.paddle.com/subscription/update?user=4&subscription=5&hash=ec2fc814538a2a92f53b2093011109c12092d7cc",
            "user_id" => "6"
          }
        )

      # Through Free Plan
      assert subscription.status == :active

      assert subscription.issued_at == s.issued_at
      assert subscription.valid_until == s.valid_until

      assert subscription.payment_attempt == "attempt_number"
    end

    test "subscription_payment_refunded", %{subscription: s} do
      {:ok, %Subscription{} = subscription} =
        PaddleClassicHandler.handler(
          %{
            assigns: %{paddle_passthrough: %{"organization_id" => s.organization_id}}
          },
          %{
            "alert_id" => "1070230122",
            "alert_name" => "subscription_payment_refunded",
            "amount" => "278.47",
            "balance_currency" => "EUR",
            "balance_earnings_decrease" => "0.39",
            "balance_fee_refund" => "0.27",
            "balance_gross_refund" => "0.27",
            "balance_tax_refund" => "0.52",
            "checkout_id" => "1-074aeb7624f8c57-3f7ab1e843",
            "currency" => "USD",
            "custom_data" => "custom_data",
            "earnings_decrease" => "0.02",
            "email" => "xzavier.flatley@example.com",
            "event_time" => "2023-07-08 01:48:54",
            "fee_refund" => "0.37",
            "gross_refund" => "0.19",
            "marketing_consent" => "",
            "order_id" => "6",
            "p_signature" =>
              "kF9lb4fQd9J0dFNjeO2HbCdvuIIqBkAMtO7n2m7kkKK6MYSIMPjPTHSczm7ct01SBbHbn5gtsYRSsMlKdUt/LUlNR3BVrZ7pzKXr2kOad7kzWpwIVZ4LtTq7DnRvyZnZNDeejdDBqXnRaspspwBaEesOcbbbZqXPw9A8/9kKtw97nL4/zjcCNyGDm49oOuDQ7RwS1qq/CCh82PP0xqQof/ke5VpkH+GMWjDlk0SL4vCi/MqGkJ334UoCJZl4quBuPloteLO/Ij1rqVsFQ/1y6V7TWU4VabwhZwpmlDdLjzLdYPPkXIGaVli8Q4xD2btPnoEao6ht9r4UWH+BU/YB2TBloJf5DhBlAPYMe0SpyK5hQBrYHnXpwWvXoZgJtjIgQVRNHhAZWvh9Q7205dgLeqfcTsXZAyycsDHWdRGArG0sFVK98emEOFaP1XGB3qRkvYQRfKQ9ltJ89X3sWkPMo+kPHu2SxD0pQj1gISTAKHh/eM+YxTUkzU4HGy8gqTlHKZOvgAEA4QxHR+Ce/PoaYR2NxXDNIHS4Ra3LCM923TYsQ3Z3W3vsGJLC+8a83n97EUR8WTX2YGPSxLKpU08hn9/qtvI6WwJ8PyXEOp2/Pkb2dsRfFr1wEzm/Tv6QScuaHezoEdPBU0BDof8OapgYol178QRR0Tbix1vLB9vJ+CA=",
            "passthrough" => "organization_id;gKg12n;user_id;gKg12n",
            "quantity" => "59",
            "refund_reason" => "refund_reason",
            "refund_type" => "vat",
            "tax_refund" => "0.51"
          }
        )

      # Through Free Plan
      assert subscription.status == :unpaid

      assert subscription.issued_at == ~U[2023-07-08 01:48:54Z]
      assert subscription.valid_until == ~U[2023-07-08 01:48:54Z]
      assert subscription.subscription_id == nil
      assert subscription.payment_attempt == nil
      assert subscription.product_id == "default"

      assert subscription.update_url == nil
      assert subscription.cancel_url == nil
    end

    test "subscription_updated", %{subscription: s} do
      {:ok, %Subscription{} = subscription} =
        PaddleClassicHandler.handler(
          %{
            assigns: %{paddle_passthrough: %{"organization_id" => s.organization_id}}
          },
          %{
            "alert_id" => "1038652886",
            "alert_name" => "subscription_updated",
            "cancel_url" =>
              "https://sandbox-checkout.paddle.com/subscription/cancel?user=6&subscription=4&hash=8e6119a4eddac1d15974712933ac3b7dcee1a1ac",
            "checkout_id" => "3-67e72571dfb9795-11a8424dfe",
            "currency" => "USD",
            "custom_data" => "custom_data",
            "email" => "jadams@example.net",
            "event_time" => "2023-07-08 01:53:27",
            "linked_subscriptions" => "7, 5, 8",
            "marketing_consent" => "",
            "new_price" => "new_price",
            "new_quantity" => "new_quantity",
            "new_unit_price" => "new_unit_price",
            "next_bill_date" => "2023-07-21",
            "old_next_bill_date" => "old_next_bill_date",
            "old_price" => "old_price",
            "old_quantity" => "old_quantity",
            "old_status" => "old_status",
            "old_subscription_plan_id" => "old_subscription_plan_id",
            "old_unit_price" => "old_unit_price",
            "p_signature" =>
              "oovhdvqyj2I+CqI1C6oiyICYvPAbex6f4DAr5lGIqoIHhmT+gUFNznoVkRteRh/TLOrI41ufzzZQz7fTykh5WGoCvYvRSDJlcfjyH49q/08r60n+y6ZBus1Qfmbd2lRYAtlg2GPX0dUXu7wNdv1Iy3uyx9OWfBnoxmCyWkKmrNyEHmoFnvOBOb1fnfALckMbOpBGMX7RtygkEHfLjWkqtrIV+Ww27hYZSqomMw8krBUC/tEYtmhdXAuVMKvpvqviaix9DI2sJnxz8SBnnY5K3eYkeyusMENAsSqQiSgwldTpcLTOOA8wmXEkcGfDq+8QNftGEkZzNV4U1pUnewCv7SLhESgIvPYcOSu+aybswqTRQpJCsGITP4RHqWBQJSdTAUN2tT4HHVYedXj+OZGYEYuA7Fu3l0SdKB/tF+9KQ3nVUprbyZH1UGn5uepUDYB1p9pQ/Cg9KCWnWbTf6QtKuKHSgO88rUYwyb611paPxubaQoxtywCtO0GAEX4K9PfqHHVxiSdNhEccE4RBWR69errG8zfhBB2wdNeiOvujLZlieIhJBFslaGZE1Nx3Sc9nt3zCDtzoOBgf9DdHYtEcU74EsBoJMZESAoTHI1/ruCJ/bEUFCrCuxrnDZbj6SwJsIRiHt9Kp8CKxGI4mnadW7HWQWBf+xhGUm8YPEEAVcZY=",
            "passthrough" => "organization_id;gKg12n;user_id;gKg12n",
            "status" => "active",
            "subscription_id" => "4",
            "subscription_plan_id" => "501",
            "update_url" =>
              "https://sandbox-checkout.paddle.com/subscription/update?user=5&subscription=2&hash=07ab94112e267c85e705053b0df646c226d950db",
            "user_id" => "50"
          }
        )

      # Through Free Plan
      assert subscription.status == :active

      assert subscription.issued_at == ~U[2023-07-08 01:53:27Z]
      assert subscription.valid_until == ~U[2023-07-21 00:00:00Z]
      assert subscription.customer_id == "50"
      assert subscription.subscription_id == "4"
      assert subscription.payment_attempt == nil
      assert subscription.product_id == "501"

      assert subscription.update_url ==
               "https://sandbox-checkout.paddle.com/subscription/update?user=5&subscription=2&hash=07ab94112e267c85e705053b0df646c226d950db"

      assert subscription.cancel_url ==
               "https://sandbox-checkout.paddle.com/subscription/cancel?user=6&subscription=4&hash=8e6119a4eddac1d15974712933ac3b7dcee1a1ac"
    end

    test "other events", %{subscription: s} do
      assert :unhandled ==
               PaddleClassicHandler.handler(
                 %{
                   assigns: %{paddle_passthrough: %{"organization_id" => s.organization_id}}
                 },
                 %{
                   "alert_id" => "1038652886",
                   "alert_name" => "other event"
                 }
               )
    end
  end
end
