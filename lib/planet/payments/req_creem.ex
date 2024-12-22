defmodule Planet.Payments.Creem do
  alias Planet.Organizations.Organization
  alias Planet.Accounts.User
  alias Planet.Payments.Plans
  require Logger

  @api_key Application.compile_env!(:planet, :creem) |> Keyword.fetch!(:api_key)
  @api_endpoint Application.compile_env!(:planet, :creem) |> Keyword.fetch!(:api_endpoint)

  # API Calls
  # defp build_url(_id, _opts \\ [])

  defp build_url("sub_" <> _id = subscription_id, opts),
    do:
      "#{@api_endpoint}/subscriptions#{build_query_params(opts ++ [subscription_id: subscription_id])}"

  defp build_url("cust_" <> _id = customer_id, opts),
    do: "#{@api_endpoint}/customers#{build_query_params(opts ++ [customer_id: customer_id])}"

  defp build_url("ch_" <> _id = checkout_id, opts),
    do: "#{@api_endpoint}/checkout#{build_query_params(opts ++ [checkout_id: checkout_id])}"

  defp build_post_url("sub_" <> _id = subscription_id, body, opts) do
    url = "#{@api_endpoint}/subscriptions/#{subscription_id}/cancel#{build_query_params(opts)}"
    {url, body}
  end

  defp build_query_params([]), do: ""
  defp build_query_params(opts), do: "?" <> URI.encode_query(opts)

  defp headers() do
    [
      {"x-api-key", "#{@api_key}"},
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

  def request_post(id, body \\ %{}, opts \\ []) do
    {url, body} = build_post_url(id, body, opts)
    body = Jason.encode!(body)

    Logger.info("Requesting #{url}")

    HTTPoison.post(url, body, headers())
    |> handle_response()
  end

  def checkout_session_url(
        %User{
          id: user_id,
          email: email,
          organization: %Organization{
            id: organization_id
          }
        },
        product_id
      ) do
    # def checkout_session_url(organization_id, price_id, email) do

    url = "#{@api_endpoint}/checkouts"

    headers = [
      {"accept", "application/json"},
      {"x-api-key", @api_key},
      {"Content-Type", "application/json"}
    ]

    # Manage the URL according to subscription, if lifetime plan ignore body
    body =
      %{
        request_id: organization_id,
        product_id: product_id,
        customer: %{
          email: email
        },
        metadata: %{
          user_id: user_id,
          organization_id: organization_id,
          product_id: product_id
        },
        success_url: Plans.checkout_success_redirect_url(:creem)
      }
      |> Jason.encode!()

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        decoded_body = Jason.decode!(response_body)

        {:ok, decoded_body}

      {:ok, %HTTPoison.Response{status_code: status_code, body: _body}} ->
        # IO.inspect(body)
        {:error, "Request failed with status code #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed with reason #{reason}"}
    end
  end

  def create_portal_session(%Planet.Subscriptions.Subscription{} = subscription) do
    url = "#{@api_endpoint}/customers/billing"

    headers = [
      {"accept", "application/json"},
      {"x-api-key", @api_key},
      {"Content-Type", "application/json"}
    ]

    body =
      %{
        "customer_id" => subscription.customer_id
      }
      |> Jason.encode!()

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        decoded_body = Jason.decode!(response_body)

        {:ok,
         %Planet.Subscriptions.Subscription{
           subscription
           | transaction_history_url: decoded_body["customer_portal_link"]
         }}

      {:ok, %HTTPoison.Response{status_code: status_code, body: _body}} ->
        # IO.inspect(body)
        {:error, "Request failed with status code #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed with reason #{reason}"}
    end
  end

  def ordered_params(params) do
    # order matters
    [
      "request_id",
      "checkout_id",
      "order_id",
      "customer_id",
      "subscription_id",
      "product_id"
    ]
    |> Enum.flat_map(fn key ->
      case Map.get(params, key) do
        nil -> []
        value -> ["#{key}=#{value}"]
      end
    end)
    |> Kernel.++(["salt=#{@api_key}"])
  end

  defp compute_signature(params) do
    params
    |> ordered_params()
    |> Enum.join("|")
    |> then(&:crypto.hash(:sha256, &1))
    |> Base.encode16(case: :lower)
  end

  def verify_signature(params, signature) do
    computed_signature = compute_signature(params)
    Plug.Crypto.secure_compare(computed_signature, signature)
  end
end
