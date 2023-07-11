defmodule AppOSWeb.SubscriptionController do
  use AppOSWeb, :controller

  require Logger

  alias AppOS.Payments.PaddleWebhookHandler

  plug(AppOS.Payments.PaddleWhitelist when action in [:paddle_webhook])
  plug(AppOS.Payments.PaddleSignatureAndPassthrough when action in [:paddle_webhook])

  plug Bodyguard.Plug.Authorize,
       [
         policy: AppOS.Policies.Organization,
         action: {Phoenix.Controller, :action_name},
         user: {AppOSWeb.UserAuthorize, :current_user},
         fallback: AppOSWeb.BodyguardFallbackController
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
      Application.fetch_env!(:appOS, :paddle)
      |> Keyword.fetch!(:vendor_id)

    paddle_sandbox? =
      Application.fetch_env!(:appOS, :paddle)
      |> Keyword.fetch!(:sandbox)

    bank_statement =
      Application.fetch_env!(:appOS, :paddle)
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

    conn
    |> render(:edit,
      license: subscription,
      plans: AppOS.Subscriptions.Plans.list(paddle_sandbox?),
      vendor_id: vendor_id,
      paddle_sandbox?: paddle_sandbox?,
      bank_statement: bank_statement,
      paddle_success_redirect_url: "#{current_url(conn)}?paddle_success=1"
    )
  end
end
