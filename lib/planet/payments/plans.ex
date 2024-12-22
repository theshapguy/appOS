defmodule Planet.Payments.Plans do
  require Logger
  alias Planet.Subscriptions.Subscription

  @default_processor Application.compile_env!(:planet, :payment) |> Keyword.fetch!(:processor)
  @payment_sandbox? Application.compile_env!(:planet, :payment) |> Keyword.fetch!(:sandbox?)
  @valid_processors [:stripe, :paddle, :creem]

  def list(billing_frequency \\ nil, exclude_free \\ true) do
    with {:ok, plans_file_path} <- choose_plans_file_path(),
         {:ok, content} <- File.read(plans_file_path),
         {:ok, decoded} <- Jason.decode(content, keys: :atoms) do
      decoded.plans
      |> filter_out_free_plans(exclude_free)
      |> filter_by_billing_frequency(billing_frequency)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @dialyzer {:nowarn_function, choose_plans_file_path: 0}
  defp choose_plans_file_path() do
    {:ok,
     if @payment_sandbox? do
       "priv/plans/plans_v1_debug.json"
     else
       "priv/plans/plans_v1.json"
     end}
  end

  defp filter_out_free_plans(plans, true) do
    plans |> Enum.filter(&(&1.productFamily != "free_plan"))
  end

  defp filter_out_free_plans(plans, false) do
    plans
  end

  defp filter_by_billing_frequency(plans, nil) do
    plans
  end

  defp filter_by_billing_frequency(plans, billing_frequency) do
    plans
    |> Enum.reduce([], fn plan, acc ->
      lifetime_variations =
        Enum.filter(plan.variations, fn variation ->
          variation.billing_frequency == billing_frequency
        end)

      case lifetime_variations do
        [] -> acc
        _variations -> [%{plan | variations: lifetime_variations} | acc]
      end
    end)
  end

  # This is used so that the lifetime plan can be displayed first
  # Moving from last of the list to the first
  def roll(array, positions \\ 1) do
    len = length(array)
    shift = rem(positions, len)
    {left, right} = Enum.split(array, len - shift)
    right ++ left
  end

  def default_plan_subscription_status() do
    case Application.fetch_env!(:planet, :payment)
         |> Keyword.fetch!(:allow_free_plan_access) do
      true -> :active
      false -> :unpaid
    end
  end

  def free_default_plan() do
    list(nil, false)
    |> Enum.find(fn plan ->
      plan.productFamily == "free_plan"
    end)
  end

  def free_default_plan_ids() do
    %{
      variations: [
        %{
          processors: %{
            manual:
              %{
                price_id: _price_id,
                product_id: _product_id
              } = manual_plan
          }
        }
        | _
      ]
    } = free_default_plan()

    manual_plan
  end

  def free_default_plan_as_subscription_attrs() do
    %{
      variations: [
        %{
          processors: %{
            manual:
              %{
                price_id: price_id,
                product_id: product_id
              } = _manual_plan
          }
        }
        | _
      ]
    } = free_default_plan()

    %{
      "processor" => "manual",
      "status" => default_plan_subscription_status(),
      "product_id" => product_id,
      "price_id" => price_id,
      "issued_at" => DateTime.utc_now(),
      # Date Plus 100 years for Free Plan
      "valid_until" => DateTime.utc_now() |> DateTime.add(3_153_600_000, :second),
      "customer_id" => nil,
      "subscription_id" => nil
    }
  end

  def variant_by_price_id(processor, price_id, exclude_free \\ true) do
    list(nil, exclude_free)
    |> Enum.find_value(fn plan ->
      plan.variations
      |> Enum.find(fn variation ->
        match = get_in(variation.processors, [processor, :price_id]) == price_id
        match
      end)
    end)
  end

  def billing_frequency_of_price_id(processor, price_id) do
    Map.get(variant_by_price_id(processor, price_id), :billing_frequency)
  end

  def enrich_subscription(%Subscription{processor: :paddle} = s) do
    portal_url = Application.fetch_env!(:planet, :paddle) |> Keyword.fetch!(:portal_endpoint)

    case Planet.Payments.Paddle.create_portal_session(s) do
      {:ok, s} -> {:ok, s}
      {:error, _reason} -> {:ok, %Subscription{s | transaction_history_url: portal_url}}
    end
  end

  def enrich_subscription(%Subscription{processor: :stripe} = s) do
    portal_url = Application.fetch_env!(:planet, :stripe) |> Keyword.fetch!(:portal_endpoint)

    case Planet.Payments.Stripe.create_portal_session(s) do
      {:ok, s} -> {:ok, s}
      {:error, _reason} -> {:ok, %Subscription{s | transaction_history_url: portal_url}}
    end
  end

  def enrich_subscription(%Subscription{processor: :creem} = s) do
    portal_url = Application.fetch_env!(:planet, :creem) |> Keyword.fetch!(:portal_endpoint)

    case Planet.Payments.Creem.create_portal_session(s) do
      {:ok, s} -> {:ok, s}
      {:error, _reason} -> {:ok, %Subscription{s | transaction_history_url: portal_url}}
    end
  end

  def enrich_subscription(%Subscription{processor: _} = s) do
    {:ok, s}
  end

  def checkout_success_redirect_url(:stripe) do
    "#{PlanetWeb.Endpoint.url()}/users/billing/verify?processor=stripe&session_id={CHECKOUT_SESSION_ID}"
  end

  def checkout_success_redirect_url(:paddle) do
    # {TRANSACTION_ID} needs to be manually repalced; unlike Stripe
    "#{PlanetWeb.Endpoint.url()}/users/billing/verify?processor=paddle&transaction_id={TRANSACTION_ID}"
  end

  def checkout_success_redirect_url(:creem) do
    "#{PlanetWeb.Endpoint.url()}/users/billing/verify?processor=creem"
  end

  def checkout_success_redirect_url(processor) do
    # IO.inspect(processor)
    Logger.error("⚠️ Unknown Redirect URL: checkout_success_redirect_url: Processor #{processor}")
    "/"
  end

  def checkout_failed_redirect_url(:stripe, session_id) do
    "/users/billing/signup?payment_failed=1&processor=stripe&session_id=#{session_id}"
  end

  def checkout_failed_redirect_url(:paddle, transaction_id) do
    "/users/billing/signup?payment_failed=1&processor=paddle&transaction_id=#{transaction_id}"
  end

  def checkout_failed_redirect_url(:creem, checkout_id) do
    "/users/billing/signup?payment_failed=1&processor=creem&checkout_id=#{checkout_id}"
  end

  def checkout_failed_redirect_url(processor, _transaction_id) do
    Logger.error("⚠️ Unknown Redirect URL: checkout_failed_redirect_url: Processor #{processor}")
    "/"
  end

  def processor(%Subscription{processor: :manual}) do
    # if manual, pick default processor from config, else pick what has been paid for before
    @default_processor
  end

  def processor(%Subscription{processor: processor})
      when processor in @valid_processors do
    processor
  end

  def processor_humanized(processor) when processor in @valid_processors do
    Application.fetch_env!(:planet, processor) |> Keyword.fetch!(:description)
  end

  def vat_included?(%Subscription{} = subscription) do
    Application.fetch_env!(:planet, subscription |> processor())
    |> Keyword.fetch!(:vat_included)
  end

  # def is_lifetime_plan?(nil) do
  #   false
  # end

  def is_lifetime_plan?(%Subscription{price_id: price_id}) do
    # Function to extract all price_ids from variations and processors
    price_ids_lifetime_plan_for_all_processors =
      list("once", true)
      |> Enum.flat_map(fn item ->
        item.variations
        |> Enum.flat_map(fn variation ->
          variation.processors
          |> Map.values()
          |> Enum.map(& &1.price_id)
        end)
      end)

    price_id in price_ids_lifetime_plan_for_all_processors
  end
end
