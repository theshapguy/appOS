defmodule Planet.Payments.Plans do
  require Logger
  alias Planet.Subscriptions.Subscription

  # @sandbox? Application.compile_env!(:planet, :payment) |> Keyword.fetch!(:sandbox?)
  @default_processor Application.compile_env!(:planet, :payment) |> Keyword.fetch!(:processor)
  # Only Add Once All Integrations are Ready
  @valid_processors [:stripe, :paddle, :creem]
  @plans_path "priv/plans/plans_v1.jsonc"

  def supported_processors() do
    @valid_processors
  end

  def default_processor() do
    @default_processor
  end

  def list(billing_frequency \\ nil, exclude_free \\ true) do
    with {:ok, content} <- read_jsonc_file!(@plans_path),
         {:ok, decoded} <- Jason.decode(content, keys: :atoms) do
      decoded.plans
      |> filter_out_free_plans(exclude_free)
      |> filter_by_billing_frequency(billing_frequency)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def coupons() do
    with {:ok, content} <- read_jsonc_file!(@plans_path),
         {:ok, decoded} <- Jason.decode(content, keys: :atoms) do
      decoded.coupons
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def coupon(coupon_code) do
    coupons()
    |> Enum.find(fn coupon ->
      coupon.code == coupon_code
    end)
  end

  @doc """
  Removing Comments from JSONC file so that Jason can parse it
  """
  def read_jsonc_file!(filename) do
    {
      :ok,
      File.stream!(filename)
      |> Stream.map(&String.trim/1)
      |> Stream.reject(&String.starts_with?(&1, "//"))
      |> Enum.to_list()
    }
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

  @doc """
  Returns the key for the payment environment to match the json file - plans_v1.json
  """
  def payment_environment_key() do
    payment_sandbox? = Application.fetch_env!(:planet, :payment) |> Keyword.fetch!(:sandbox?)

    if(payment_sandbox?, do: :sandbox, else: :live)
  end

  def get_plan_by_enviroment(
        # Pattern matching so keeping this structure to make sure we get the correct format
        %{
          sandbox:
            %{
              price_id: _sandbox_price_id,
              product_id: _sandbox_product_id
            } = _sandbox_plan,
          live:
            %{
              price_id: _live_price_id,
              product_id: _live_product_id
            } = _live_plan
        } = plan
      ) do
    get_in(
      plan,
      [payment_environment_key()]
    )
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
            manual: plan
          }
        }
        | _
      ]
    } = free_default_plan()

    plan |> get_plan_by_enviroment()
  end

  def free_default_plan_as_subscription_attrs() do
    %{
      price_id: price_id,
      product_id: product_id
    } = free_default_plan_ids()

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
        match =
          get_in(variation.processors, [processor, payment_environment_key(), :price_id]) ==
            price_id

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
    Logger.error("⚠️ Unknown Redirect URL: checkout_success_redirect_url: Processor #{processor}")
    "/users/billing/verify?processor=UNKNOWN&fix_code=1"
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
    "/users/billing/signup?payment_failed=1&processor=UNKNOWN&checkout_id=UNKNOWN"
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

  @doc """
  Check if the subscription is a lifetime plan

  If subscription id is nil, subscription was activated manually so need to allow futher updates
  to get full details of the transaction.completed webhook

  Hence checking with subscription_id
  """
  def webhook_check_is_lifetime_plan?(%Subscription{
        price_id: price_id,
        subscription_id: nil
      })
      when is_binary(price_id) do
    false
  end

  def webhook_check_is_lifetime_plan?(%Subscription{
        price_id: price_id,
        subscription_id: subscription_id
      })
      when is_binary(subscription_id) and is_binary(price_id) do
    # Function to extract all price_ids from variations and processors
    price_ids_lifetime_plan_for_all_processors =
      list("once", true)
      |> Enum.flat_map(fn item ->
        item.variations
        |> Enum.flat_map(fn variation ->
          variation.processors
          |> Map.values()
          |> Enum.flat_map(fn processor ->
            processor
            # Filter out keys for the current environment
            |> Map.filter(fn {key, _} -> key == payment_environment_key() end)
            |> Map.values()
            |> Enum.map(& &1.price_id)
          end)
        end)
      end)

    price_id in price_ids_lifetime_plan_for_all_processors
  end
end
