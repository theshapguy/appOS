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
        level: 10
      },
      %Subscription{
        product_id: "pro_01jczp7xcy9wsszr9r5nx26qzh",
        price: "$10",
        title: "Plus Plan",
        subtitle: "Starter plus more",
        level: 20
      },
      %Subscription{
        product_id: "54405",
        price: "$20",
        title: "Pro Plan",
        subtitle: "Plus plus more",
        level: 30
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
