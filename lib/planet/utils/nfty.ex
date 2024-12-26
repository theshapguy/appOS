defmodule Planet.Utils.Nfty do
  require Logger

  alias Planet.HTTPRequest
  alias Planet.EctoType.HashId
  alias Planet.Subscriptions.Subscription

  @headers [
    {"Content-Type", "application/x-www-form-urlencoded"}
  ]

  defp nfty_url() do
    Application.get_env(:planet, Planet.Mailer)[:ntfy_url]
  end

  def notify(%Subscription{} = subscription) do
    body = """
      Failed Payment Webhook Update

      Id: #{HashId.dump(subscription.organization_id) |> elem(1)}
      HashId: #{subscription.organization_id}
      CustomerId: #{subscription.customer_id}
      PriceId: #{subscription.price_id}
      LastUpdatedUTC: #{subscription.updated_at}
    """

    IO.inspect(subscription.updated_at)

    # LastUpdated: #{subscription.updated_at |> Timex.to_datetime("Asia/Kathmandu") |> Timex.format!("{YYYY}-{0M}-{0D} {h12}:{m} {AM}")}

    case HTTPRequest.post(nfty_url(), body, @headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        # Success Code for Oban
        :ok

      _ ->
        # Retry Code for Oban
        :error
    end
  end

  def notify(body) when is_binary(body) do
    case HTTPRequest.post(nfty_url(), body, @headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        decoded_body = Jason.decode!(response_body)
        {:ok, decoded_body}

      other_body ->
        Logger.debug(other_body)
        # Retry Code for Oban
        :error
    end
  end
end
