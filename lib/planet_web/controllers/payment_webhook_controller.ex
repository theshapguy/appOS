defmodule PlanetWeb.PaymentWebhookController do
  use PlanetWeb, :controller
  require Logger

  alias Planet.Storage.StripeWebhookEventsDB

  alias Planet.Payments.StripeHandler
  alias Planet.Payments.PaddleHandler
  alias Planet.Payments.CreemHandler

  alias Planet.Payments.Creem
  alias Planet.Payments.Stripe

  # Only Checking for Stripe Webhook Events After Signature Verification
  plug(Planet.Plug.StripeWhitelist when action in [:stripe_webhook])
  plug(Planet.Plug.StripeSignature when action in [:stripe_webhook])
  # plug(Planet.Plug.StripeUniqueWebhookEvents when action in [:stripe_webhook])

  plug(Planet.Plug.PaddleSignature when action in [:paddle_webhook])
  plug(Planet.Plug.PaddleWhitelist when action in [:paddle_webhook])

  plug(Planet.Plug.CreemSignature when action in [:creem_webhook])

  # Webhooks
  def paddle_webhook(conn, params) do
    case PaddleHandler.handler(conn, params) do
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

  def stripe_webhook(
        conn,
        %{
          "id" => "evt_" <> _ = event_id,
          "type" => event_type,
          "created" => created,
          "data" => %{
            "object" => %{"id" => object_id}
          }
        } = params
      ) do
    case StripeHandler.handler(params) do
      {:ok, sub} ->
        StripeWebhookEventsDB.store_webhook_event(event_id, event_type, object_id, created)

        conn
        |> put_status(:ok)
        |> json(%{message: "success", subscription: %{data: sub}})

      {:error, changeset} ->
        Logger.error(changeset.errors)

        conn
        |> put_status(:bad_request)
        |> json(%{message: "failed"})

      :unhandled ->
        StripeWebhookEventsDB.store_webhook_event(event_id, event_type, object_id, created)

        conn
        |> put_status(:ok)
        |> json(%{message: "no content"})
    end
  end

  def creem_webhook(conn, params) do
    case CreemHandler.handler(params) do
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

  # Generate Checkout Session Link For Creem
  def payment_checkout_session(conn, %{
        "price_id" => price_id,
        "processor" => "creem"
      }) do
    current_user = conn.assigns.current_user

    case Creem.checkout_session_url(
           current_user,
           price_id
         ) do
      {:ok, body} ->
        conn
        |> put_status(:ok)
        |> json(%{message: "success", checkout_url: body["checkout_url"]})

      {:error, _e} ->
        conn
        |> put_status(:bad_request)
        |> json(%{message: "failed"})
    end
  end

  # Generate Checkout Session Link For Stripe
  def payment_checkout_session(conn, %{
        "price_id" => price_id,
        "processor" => "stripe"
      }) do
    current_user = conn.assigns.current_user

    case Stripe.checkout_session_url(
           current_user,
           price_id
         ) do
      {:ok, body} ->
        conn
        |> put_status(:ok)
        |> json(%{message: "success", checkout_url: body["url"]})

      {:error, _e} ->
        conn
        |> put_status(:bad_request)
        |> json(%{message: "failed"})
    end
  end
end
