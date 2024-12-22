defmodule Planet.Plug.StripeUniqueWebhookEvents do
  @moduledoc """
  A plug to ensure Stripe webhook requests are idempotent by storing their IDs
  (event_id, event_type, object_id) in Mnesia and preventing reprocessing of
  the same event.

  https://docs.stripe.com/webhooks#handle-duplicate-events
  """
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]
  require Logger
  alias Jason
  alias Planet.Storage.StripeWebhookEventsDB

  def init(opts), do: opts

  def call(conn, _opts) do
    body = PlanetWeb.CacheBodyReader.get_raw_body(conn)

    with {:ok,
          %{
            "id" => "evt_" <> _ = event_id,
            "type" => event_type,
            "created" => _created,
            "data" => %{
              "object" => %{"id" => object_id}
            }
          }} <- Jason.decode(body),
         {:not_found, _} <- StripeWebhookEventsDB.has_event(event_id, event_type, object_id) do
      conn
    else
      {:found, _} ->
        conn
        |> failed_response("failed: duplicate Stripe event - already processed")

      {:error, %Jason.DecodeError{}} ->
        conn
        |> failed_response("failed: json decoder")

      _ ->
        conn
        |> failed_response("failed: other reason")
    end
  end

  defp failed_response(conn, message) do
    Logger.error("Failed to decode Stripe event: #{message}")

    conn
    |> put_status(:bad_request)
    |> json(%{message: message})
    |> halt()
  end
end
