defmodule Planet.Subscriptions.Plans do
  alias Planet.Subscriptions.Subscription

  def list(sandbox? \\ false) do
    # Live Plans
    plans = [
      %Subscription{
        product_id: "default",
        price: "",
        title: "Starter",
        subtitle: "Free plan with all the basics",
        level: 10,
        period: :month,
        price_id: ""
      },
      %Subscription{
        product_id: "pro_01jczp7xcy9wsszr9r5nx26qzh",
        price_id: "pri_01jczwfy1wwejsm0zw7yzc1qze",
        price: "$50",
        title: "Plus Plan",
        subtitle: "Starter plus more",
        level: 20,
        period: :month
      },
      %Subscription{
        product_id: "pro_01jczp7xcy9wsszr9r5nx26qzh",
        price_id: "pri_01je03xvqpmaxc2xvz27dqwm88",
        price: "$100",
        title: "Pro Plan",
        subtitle: "Plus plus more",
        level: 30,
        period: :month
      },
      %Subscription{
        product_id: "pro_01jczp7xcy9wsszr9r5nx26qzh",
        price_id: "pri_01je046z9z9cz6sqt73ggrwyde",
        price: "$500",
        title: "Lifetime Plan",
        subtitle: "Lifetime access to all features",
        level: -1,
        period: :lifetime
      }
    ]

    if sandbox? do
      # Add Test Plan
      [
        %Subscription{
          # Do Not Remove This Plan
          product_id: "__test__plan__",
          price: "$$",
          title: "Test Plan",
          subtitle: "Test plan (does not exist in paddle/stripe - is not subscribable)",
          level: 100
        }
        | plans
      ]
    else
      plans
    end
  end

  def get_default_plan do
    %{
      "status" => :active,
      "product_id" => "default",
      "issued_at" => DateTime.utc_now(),
      # Date Plus 100 years for Free Plan
      "valid_until" => DateTime.utc_now() |> DateTime.add(3_153_600_000, :second)
    }
  end

  def get_level_by_product_id(product_id) do
    Enum.find(list(), fn map -> map.product_id == product_id end)
  end

  def check_upgrade_downgrade_or_current_plan(%Subscription{} = license, %Subscription{} = plan) do
    license_product_id = get_level_by_product_id(license.product_id)
    plan_product_id = get_level_by_product_id(plan.product_id)

    cond do
      license_product_id == plan_product_id -> :current
      license_product_id < plan_product_id -> :upgrade
      license_product_id > plan_product_id -> :downgrade
    end
  end
end
