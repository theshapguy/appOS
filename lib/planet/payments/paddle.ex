defmodule Planet.Payments.Paddle do
  require Logger
  # API Calls

  # defp build_url(id, opts \\ [])

  defp build_url("txn_" <> _id = transaction_id, opts),
    do: "#{api_endpoint()}/transactions/#{transaction_id}#{build_query_params(opts)}"

  defp build_url("ctm_" <> _id = customer_id, opts),
    do: "#{api_endpoint()}/customers/#{customer_id}#{build_query_params(opts)}"

  defp build_url("sub_" <> _id = subscription_id, opts),
    do: "#{api_endpoint()}/subscriptions/#{subscription_id}#{build_query_params(opts)}"

  defp build_query_params([]), do: ""
  defp build_query_params(opts), do: "?" <> URI.encode_query(opts)

  defp headers() do
    [
      {"Authorization", "Bearer #{api_key()}"},
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

    HTTPoison.get(url, headers())
    |> handle_response()
  end

  # Portal Calls

  # Config
  defp api_key() do
    Application.fetch_env!(:planet, :paddle)
    |> Keyword.fetch!(:billing_api_key)
  end

  defp api_endpoint() do
    Application.fetch_env!(:planet, :paddle)
    |> Keyword.fetch!(:api_endpoint)
  end
end
