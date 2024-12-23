defmodule PlanetWeb.SubscriptionController do
  use PlanetWeb, :controller

  alias Planet.Subscriptions
  alias Planet.Payments.Plans

  alias Planet.Payments.Creem
  alias Planet.Payments.Stripe
  alias Planet.Payments.Paddle

  import Planet.Payments.PaddleHandler, only: [convert_paddle_webhook_datetime: 1]
  import Planet.Payments.CreemHandler, only: [convert_creem_webhook_datetime: 1]

  plug(Planet.Plug.SubscriptionManagementRedirect when action in [:edit, :payment])
  plug Planet.Plug.PageTitle, title: "Billing"

  # plug Bodyguard.Plug.Authorize,
  #      [
  #        policy: Planet.Policies.Organization,
  #        action: {Phoenix.Controller, :action_name},
  #        user: {PlanetWeb.UserAuthorize, :current_user},
  #        fallback: PlanetWeb.BodyguardFallbackController
  #      ]
  #      when action in [:edit, :payment]

  def edit(conn, _params) do
    current_user = conn.assigns.current_user
    subscription = current_user.organization.subscription

    payment_processor =
      Application.fetch_env!(:planet, :payment)
      |> Keyword.fetch!(:processor)

    bank_statement =
      Application.fetch_env!(:planet, payment_processor)
      |> Keyword.fetch!(:bank_statement)

    {:ok, subscription_with_portal} =
      Planet.Payments.Plans.enrich_subscription(subscription)

    conn
    |> render(:edit,
      current_user: current_user,
      license: subscription_with_portal,
      bank_statement: bank_statement,
      current_plan: Plans.variant_by_price_id(subscription.processor, subscription.price_id)
    )
  end

  # Payment On Signup
  def payment(conn, params) do
    filter_lifetime_querystring = if Map.get(params, "lifetime") == "yes", do: "once"
    subscription = conn.assigns.current_user.organization.subscription

    payment_sandbox? =
      Application.fetch_env!(:planet, :payment)
      |> Keyword.fetch!(:sandbox?)

    selected_processor = Plans.processor(subscription)

    conn
    |> maybe_add_payment_failed_flash(params)
    |> render(:payment,
      payment_sandbox?: payment_sandbox?,
      subscription_plans: Plans.list(filter_lifetime_querystring, true) |> Plans.roll(),
      lifetime_plans_only?: filter_lifetime_querystring == "once",
      processor: selected_processor,
      processor_humanized: Plans.processor_humanized(selected_processor),
      vat_included?: Plans.vat_included?(subscription),
      success_redirect_url: Plans.checkout_success_redirect_url(selected_processor)
    )
  end

  defp maybe_add_payment_failed_flash(conn, %{"payment_failed" => "1"}) do
    conn
    |> put_flash(:error, "We could not process/verify your payment. Refresh & Try Again.")
  end

  defp maybe_add_payment_failed_flash(conn, _) do
    conn
  end

  @doc """
  This method allows a temporary access to the app for 60 minutes,
  since paddle redirects it into this method.
  """
  def verify(conn, %{
        "transaction_id" => "txn_" <> _id = transaction_id,
        "processor" => "paddle" = processor
      }) do
    failed_redirect_url =
      Plans.checkout_failed_redirect_url(String.to_existing_atom(processor), transaction_id)

    case Paddle.request(transaction_id) do
      {:ok,
       %{
         "data" => %{
           "status" => status,
           "created_at" => created_at,
           "custom_data" => %{
             "organization_id" => organization_id
           }
         }
       }}
      when status in ["billed", "completed", "paid"] ->
        case Subscriptions.maybe_force_active(%{
               "organization_id" => organization_id,
               "timestamp" => "#{convert_paddle_webhook_datetime(created_at) |> Timex.to_unix()}"
             }) do
          {:ok, _subscription} ->
            conn
            |> put_flash(:info, "Your subscription has been activated.")
            |> redirect(to: ~p"/app?greeting=hi")

          {:error, _error} ->
            conn |> failed_to_activate(failed_redirect_url)
        end

      {:ok, _error} ->
        conn |> failed_to_activate(failed_redirect_url)

      {:error, _error} ->
        conn |> failed_to_activate(failed_redirect_url)
    end
  end

  def verify(conn, %{
        "processor" => "stripe" = processor,
        "session_id" => "cs_" <> _id = session_id
      }) do
    failed_redirect_url =
      Plans.checkout_failed_redirect_url(String.to_existing_atom(processor), session_id)

    case Stripe.request(session_id) do
      {:ok,
       %{
         "status" => "complete",
         "created" => created,
         "metadata" => %{
           "organization_id" => organization_id,
           "price_id" => _price_id,
           "product_id" => _product_id
         }
       }} ->
        case Subscriptions.maybe_force_active(%{
               "organization_id" => organization_id,
               "timestamp" => "#{created}"
             }) do
          {:ok, _subscription} ->
            conn
            |> put_flash(:info, "Your subscription has been activated.")
            |> redirect(to: "/app?greeting=hi")

          {:error, _error} ->
            conn |> failed_to_activate(failed_redirect_url)
        end

      {:ok, _} ->
        conn |> failed_to_activate(failed_redirect_url)

      {:error, _} ->
        conn |> failed_to_activate(failed_redirect_url)
    end
  end

  def verify(
        conn,
        %{
          "processor" => "creem" = processor,
          "checkout_id" => checkout_id,
          "signature" => signature,
          # Using Request Id In Organzation Id, Since No Order Verification API available
          "request_id" => _organization_id
        } = params
      ) do
    failed_redirect_url =
      Plans.checkout_failed_redirect_url(String.to_existing_atom(processor), checkout_id)

    subscription_id = Map.get(params, "subscription_id", nil)

    with true <- Creem.verify_signature(params, signature),
         {:ok,
          %{
            "status" => "active",
            "current_period_start_date" => start_date,
            "metadata" => %{"organization_id" => organization_id}
          }} <- maybe_verify_creem_order_id(params, subscription_id),
         {:ok, _subscription} <-
           activate_subscription(%{
             "organization_id" => organization_id,
             "current_period_start_date" => start_date
           }) do
      conn
      |> put_flash(:info, "Your subscription has been activated.")
      |> redirect(to: "/app?greeting=hi")
    else
      _ -> failed_to_activate(conn, failed_redirect_url)
    end
  end

  defp maybe_verify_creem_order_id(params, nil) do
    # Mock since one time payment is not verifiable yet
    # Assuming it is verified when redirect is made
    {:ok,
     %{
       "status" => "active",
       "current_period_start_date" =>
         Timex.now()
         |> Timex.set(timezone: "UTC")
         |> Timex.format!("{ISO:Extended:Z}"),
       "metadata" => %{
         "organization_id" => Map.fetch!(params, "request_id")
       }
     }}
  end

  defp maybe_verify_creem_order_id(_, subscription_id) do
    Creem.request(subscription_id)
  end

  defp failed_to_activate(conn, failed_redirect_url) do
    conn
    |> put_flash(:error, "Failed to activate subscription.")
    |> redirect(to: failed_redirect_url)
  end

  defp activate_subscription(%{
         "organization_id" => org_id,
         "current_period_start_date" => start_date
       }) do
    timestamp =
      start_date
      |> convert_creem_webhook_datetime()
      |> Timex.to_unix()
      |> to_string()

    Subscriptions.maybe_force_active(%{
      "organization_id" => org_id,
      "timestamp" => timestamp
    })
  end

  # Payment On Signup #For Paddle
  def transaction(conn, %{"_ptxn" => _}) do
    payment_debug? =
      Application.fetch_env!(:planet, :payment)
      |> Keyword.fetch!(:sandbox?)

    conn
    |> render(
      :transaction,
      payment_debug?: payment_debug?
    )
  end
end
