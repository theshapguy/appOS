defmodule PlanetWeb.SubscriptionController do
  use PlanetWeb, :controller

  plug PlanetWeb.Plugs.PageTitle, title: "Billing"

  require Logger

  alias Planet.Subscriptions
  alias Planet.Utils
  alias Planet.Payments.PaddleWebhookHandler

  plug(Planet.Payments.PaddleWhitelist when action in [:paddle_webhook])
  plug(Planet.Payments.PaddleSignatureAndPassthrough when action in [:paddle_webhook])

  plug Bodyguard.Plug.Authorize,
       [
         policy: Planet.Policies.Organization,
         action: {Phoenix.Controller, :action_name},
         user: {PlanetWeb.UserAuthorize, :current_user},
         fallback: PlanetWeb.BodyguardFallbackController
       ]
       when action in [:edit]

  def paddle_webhook(conn, params) do
    case PaddleWebhookHandler.handler(conn, params) do
      # If attrs is same as update what happens,
      # send subscription created then payment succeded to chck

      {:ok, _} ->
        conn
        |> put_status(:ok)
        |> json(%{message: "success"})

      {:error, changeset} ->
        Logger.error(changeset.errors)

        conn
        |> put_status(:bad_request)
        |> json(%{message: "failed"})

      :unhandled ->
        conn
        |> put_status(:ok)
        |> json(%{message: "no content"})
    end
  end

  def edit(conn, params) do
    organization = conn.assigns.current_user.organization
    subscription = organization.subscription

    vendor_id =
      Application.fetch_env!(:planet, :paddle)
      |> Keyword.fetch!(:vendor_id)

    paddle_sandbox? =
      Application.fetch_env!(:planet, :paddle)
      |> Keyword.fetch!(:sandbox)

    bank_statement =
      Application.fetch_env!(:planet, :paddle)
      |> Keyword.fetch!(:bank_statement)

    conn =
      if Map.get(params, "paddle_success", nil) == "1" do
        conn
        |> put_flash(
          :info,
          "It may take a few seconds for your plan to activate."
        )
      else
        conn
      end

    challenge = "organization_id=#{organization.id},timestamp=#{Timex.now() |> Timex.to_unix()}"

    conn
    |> render(:edit,
      license: subscription,
      plans: Planet.Subscriptions.Plans.list(paddle_sandbox?),
      vendor_id: vendor_id,
      paddle_sandbox?: paddle_sandbox?,
      bank_statement: bank_statement,
      paddle_success_redirect_url:
        "/users/billing/verify?paddle=1&challenge=#{Utils.encrypt_string(challenge)}"
    )
  end

  # Payment On Signup
  def payment(conn, _params) do
    organization = conn.assigns.current_user.organization

    vendor_id =
      Application.fetch_env!(:planet, :paddle)
      |> Keyword.fetch!(:vendor_id)

    paddle_sandbox? =
      Application.fetch_env!(:planet, :paddle)
      |> Keyword.fetch!(:sandbox)

    challenge = "organization_id=#{organization.id},timestamp=#{Timex.now() |> Timex.to_unix()}"

    conn
    |> render(:payment,
      vendor_id: vendor_id,
      paddle_sandbox?: paddle_sandbox?,
      paddle_success_redirect_url:
        "/users/billing/verify?paddle=1&challenge=#{Utils.encrypt_string(challenge)}"
      # paddle_success_redirect_url: "#{current_url(conn)}?paddle_success=1"
    )
  end

  @doc """
  This method allows a temporary access to the app for 60 minutes,
  since paddle redirects it into this method.
  """
  def verify(conn, %{"challenge" => token}) do
    # %{"organiaztion_id" => "gKg12n", "timestamp" => "1720526761"}

    attrs =
      Utils.decrypt_string!(token)
      |> Utils.string_to_attrs()

    case Subscriptions.maybe_force_active(attrs) do
      {:ok, _subscription} ->
        conn
        |> put_flash(:info, "Your subscription has been activated.")
        |> redirect(to: "/app")

      {:error, _error} ->
        conn
        |> put_flash(:error, "Failed to activate subscription.")
        |> redirect(to: "/users/billing/signup")
    end

    # conn
    # |> redirect(to: "/app")

    # conn
    # |> render(:verify)
  end
end
