defmodule Planet.Payments.Paddle do
  alias Planet.HTTPRequest
  require Logger

  @api_key Application.compile_env!(:planet, :paddle) |> Keyword.fetch!(:api_key)
  @api_endpoint Application.compile_env!(:planet, :paddle) |> Keyword.fetch!(:api_endpoint)

  # API Calls
  # defp build_url(id, opts \\ [])

  defp build_url("txn_" <> _id = transaction_id, opts),
    do: "#{@api_endpoint}/transactions/#{transaction_id}#{build_query_params(opts)}"

  defp build_url("ctm_" <> _id = customer_id, opts),
    do: "#{@api_endpoint}/customers/#{customer_id}#{build_query_params(opts)}"

  defp build_url("sub_" <> _id = subscription_id, opts),
    do: "#{@api_endpoint}/subscriptions/#{subscription_id}#{build_query_params(opts)}"

  defp build_url("webhook_ips", _opts),
    do: "#{@api_endpoint}/ips"

  defp build_post_url("sub_" <> _id = subscription_id, body, opts) do
    url = "#{@api_endpoint}/subscriptions/#{subscription_id}/cancel#{build_query_params(opts)}"
    {url, body}
  end

  defp build_query_params([]), do: ""
  defp build_query_params(opts), do: "?" <> URI.encode_query(opts)

  defp headers() do
    [
      {"Authorization", "Bearer #{@api_key}"},
      {"Content-Type", "application/json"}
    ]
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: response_body}}) do
    decoded_body = Jason.decode!(response_body)
    {:ok, decoded_body}
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}}) do
    Logger.info("Request failed with status code #{status_code} and body #{body}")
    {:error, "Request failed with status code #{status_code}"}
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, "Request failed with reason #{reason}"}
  end

  def request(id, opts \\ []) do
    url = build_url(id, opts)

    Logger.info("Requesting #{url}")

    HTTPRequest.get(url, headers())
    |> handle_response()
  end

  def request_post(id, body \\ %{}, opts \\ []) do
    {url, body} = build_post_url(id, body, opts)
    body = Jason.encode!(body)

    Logger.info("Requesting #{url}")

    HTTPRequest.post(url, body, headers())
    |> handle_response()
  end

  ### POST Requests
  def create_portal_session(%Planet.Subscriptions.Subscription{} = subscription) do
    url = "#{@api_endpoint}/customers/#{subscription.customer_id}/portal-sessions"

    # headers = [
    #   {"Authorization", "Bearer #{@api_key}"},
    #   {"Content-Type", "application/json"}
    # ]

    # Manage the URL according to subscription, if lifetime plan ignore body
    body =
      case subscription.subscription_id do
        "sub_" <> _ ->
          %{"subscription_ids" => [subscription.subscription_id]}

        _ ->
          %{}
      end
      |> Jason.encode!()

    case HTTPRequest.post(url, body, headers()) do
      {:ok, %HTTPoison.Response{status_code: 201, body: response_body}} ->
        decoded_body = Jason.decode!(response_body)

        {:ok, update_subscription_with_response(subscription, decoded_body)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: _body}} ->
        {:error, "Request failed with status code #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed with reason #{reason}"}
    end
  end

  defp update_subscription_with_response(%Planet.Subscriptions.Subscription{} = subscription, %{
         "data" => %{
           "urls" => %{
             "general" => %{
               "overview" => overview_url
             },
             "subscriptions" => [
               %{
                 "cancel_subscription" => cancel_url,
                 "update_subscription_payment_method" => update_payment_method_url
               }
               | _
             ]
           }
         }
       }) do
    %Planet.Subscriptions.Subscription{
      subscription
      | cancel_url: cancel_url,
        update_url: update_payment_method_url,
        transaction_history_url: create_payment_page_url(overview_url)
    }
  end

  defp update_subscription_with_response(%Planet.Subscriptions.Subscription{} = subscription, %{
         "data" => %{
           "urls" => %{
             "general" => %{
               "overview" => overview_url
             }
           }
         }
       }) do
    %Planet.Subscriptions.Subscription{
      subscription
      | cancel_url: overview_url,
        update_url: overview_url,
        transaction_history_url: create_payment_page_url(overview_url)
    }
  end

  defp create_payment_page_url(overview_url) do
    uri = URI.parse(overview_url)

    params =
      URI.decode_query(uri.query || "")
      |> Map.delete("action")
      |> Map.delete("subscription_id")
      |> Map.put("action", "payment")

    transaction_history_uri = %{uri | query: URI.encode_query(params)}
    URI.to_string(transaction_history_uri)
  end
end
