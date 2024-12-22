defmodule PlanetWeb.SubscriptionHTML do
  use PlanetWeb, :html
  require Logger

  embed_templates("subscription_html/*")

  def humanize_payment_term(billing_frequency) do
    case billing_frequency do
      "once" -> "Billed once"
      "monthly" -> "Billed monthly"
      "quarterly" -> "Billed every 3 months"
      "annually" -> "Billed yearly"
      _ -> Logger.error("Unknown billing frequency: #{billing_frequency}")
    end
  end
end
