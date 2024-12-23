defmodule Planet.Payments.Stripe do
  alias Planet.HTTPRequest
  alias Planet.Organizations.Organization
  alias Planet.Subscriptions.Subscription
  alias Planet.Accounts.User
  alias Planet.Payments.Plans
  require Logger

  @api_key Application.compile_env!(:planet, :stripe) |> Keyword.fetch!(:api_key)
  @api_endpoint Application.compile_env!(:planet, :stripe) |> Keyword.fetch!(:api_endpoint)
  @webhook_ips_url "https://stripe.com/files/ips/ips_webhooks.json"

  defp build_url("cs_" <> _id = checkout_session_id, opts),
    do: "#{@api_endpoint}/checkout/sessions/#{checkout_session_id}#{build_query_params(opts)}"

  defp build_url("in_" <> _id = invoice_id, opts),
    do: "#{@api_endpoint}/invoices/#{invoice_id}#{build_query_params(opts)}"

  defp build_url("sub_" <> _id = subscription_id, opts),
    do: "#{@api_endpoint}/subscriptions/#{subscription_id}#{build_query_params(opts)}"

  defp build_url("webhook_ips", _opts),
    do: "https://stripe.com/files/ips/ips_webhooks.txt"

  defp build_query_params([]), do: ""
  defp build_query_params(opts), do: "?" <> URI.encode_query(opts)

  defp headers() do
    [
      {"Authorization", "Basic " <> Base.encode64("#{@api_key}:")},
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

  # Doing it this way because the webhook_ips_url is not a part of the API
  # But trying to match the same pattern as the other payment requests
  def request("webhook_ips") do
    url = @webhook_ips_url
    Logger.info("Requesting #{url}")

    HTTPRequest.get(url)
    |> handle_response()
  end

  def request(id, opts \\ []) do
    url = build_url(id, opts)
    Logger.info("Requesting #{url}")

    HTTPRequest.get(url, headers())
    |> handle_response()
  end

  def request_delete(id, opts \\ []) do
    url = build_url(id, opts)
    Logger.info("Requesting DELETE: #{url}")

    HTTPRequest.delete(url, headers())
    |> handle_response()
  end

  # def maybe_add_customer_creation_param(params, "payment") do
  #   Map.put(params, "customer_creation", "always")
  # end

  # def maybe_add_customer_creation_param(params, _) do
  #   params
  # end

  def maybe_add_customer_details(
        params,
        %User{
          email: email,
          organization: %Organization{
            subscription: %Subscription{
              customer_id: nil
            }
          }
        },
        payment_mode
      ) do
    params =
      params
      |> Map.put("customer_email", email)

    case payment_mode do
      "payment" ->
        params
        |> Map.put("customer_creation", "always")

      _other ->
        params
    end
  end

  def maybe_add_customer_details(
        params,
        %User{
          email: _email,
          organization: %Organization{
            subscription: %Subscription{
              customer_id: customer_id
            }
          }
        },
        _payment_mode
      ) do
    Map.put(params, "customer", customer_id)
  end

  def maybe_add_customer_creation(params, "payment") do
    Map.put(params, "customer_creation", "always")
  end

  def maybe_add_customer_creation(params, _) do
    params
  end

  defp maybe_add_subscription_metadata(params, "subscription") do
    %{
      "subscription_data[metadata][price_id]" => Map.get(params, "metadata[price_id]"),
      "subscription_data[metadata][product_id]" => Map.get(params, "metadata[product_id]"),
      "subscription_data[metadata][organization_id]" =>
        Map.get(params, "metadata[organization_id]"),
      "subscription_data[metadata][user_id]" => Map.get(params, "metadata[user_id]")
    }
    |> Map.merge(params)
  end

  defp maybe_add_subscription_metadata(params, "payment") do
    params
  end

  # POST Calls
  def checkout_session_url(
        %User{
          id: user_id,
          organization: %Organization{
            id: organization_id,
            subscription: %Subscription{
              organization_id: _subscription_id
            }
          }
        } = user,
        price_id
      ) do
    # def checkout_session_url(organization_id, price_id, email) do
    url = "#{@api_endpoint}/checkout/sessions"

    %{billing_frequency: frequency} = Plans.variant_by_price_id(:stripe, price_id)

    %{price_id: ^price_id, product_id: product_id} =
      Plans.variant_by_price_id(:stripe, price_id).processors.stripe

    mode = if(frequency == "once", do: "payment", else: "subscription")

    body =
      %{
        "line_items[0][price]" => price_id,
        "line_items[0][quantity]" => 1,
        "metadata[price_id]" => price_id,
        "metadata[product_id]" => product_id,
        "metadata[organization_id]" => organization_id,
        "metadata[user_id]" => user_id,
        "client_reference_id" => organization_id,
        # Choose mode according to billing frequency
        "mode" => mode,
        "success_url" => Plans.checkout_success_redirect_url(:stripe)
        # Use Stripe Organizations As An Alternative
        # "payment_intent_data[statement_descriptor]" => "",
        # "payment_intent_data[statement_descriptor_suffix]" => "",
      }
      |> maybe_add_customer_details(user, mode)
      |> maybe_add_subscription_metadata(mode)
      |> URI.encode_query()

    headers = [
      {"Authorization", "Basic " <> Base.encode64("#{@api_key}:")},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    case HTTPRequest.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        {:ok, Jason.decode!(response_body)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: _body}} ->
        {:error, "Request failed with status code #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed with reason #{reason}"}
    end
  end

  def create_portal_session(%Planet.Subscriptions.Subscription{} = subscription) do
    url = "#{@api_endpoint}/billing_portal/sessions"

    headers = [
      {"Authorization", "Basic " <> Base.encode64("#{@api_key}:")},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    # Manage the URL according to subscription, if lifetime plan ignore body
    body =
      %{
        # "return_url" => "#{PlanetWeb.Endpoint.url()}/users/billing/signup",
        "return_url" => "#{PlanetWeb.Endpoint.url()}/users/billing/",
        "customer" => subscription.customer_id
      }
      |> URI.encode_query()

    case HTTPRequest.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        decoded_body = Jason.decode!(response_body)

        {:ok,
         %Planet.Subscriptions.Subscription{
           subscription
           | transaction_history_url: decoded_body["url"]
         }}

      {:ok, %HTTPoison.Response{status_code: status_code, body: _body}} ->
        {:error, "Request failed with status code #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed with reason #{reason}"}
    end
  end
end
