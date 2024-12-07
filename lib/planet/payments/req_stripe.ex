defmodule Planet.Payments.Stripe do
  alias Planet.Organizations.Organization
  alias Planet.Subscriptions.Subscription
  alias Planet.Accounts.User
  alias Planet.Payments.Plans
  require Logger

  @api_key Application.compile_env!(:planet, :stripe) |> Keyword.fetch!(:api_key)
  @api_endpoint Application.compile_env!(:planet, :stripe) |> Keyword.fetch!(:api_endpoint)

  defp build_url("cs_" <> _id = checkout_session_id, opts),
    do: "#{@api_endpoint}/checkout/sessions/#{checkout_session_id}#{build_query_params(opts)}"

  defp build_url("in_" <> _id = invoice_id, opts),
    do: "#{@api_endpoint}/invoices/#{invoice_id}#{build_query_params(opts)}"

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

  def request(id, opts \\ []) do
    url = build_url(id, opts)
    Logger.info("Requesting #{url}")

    HTTPoison.get(url, headers())
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

    %{billingFrequency: frequency} = Plans.variant_by_price_id(:stripe, price_id)

    %{priceId: ^price_id, productId: product_id} =
      Plans.variant_by_price_id(:stripe, price_id).processors.stripe

    mode = if(frequency == "lifetime", do: "payment", else: "subscription")

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
      |> URI.encode_query()

    headers = [
      {"Authorization", "Basic " <> Base.encode64("#{@api_key}:")},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        {:ok, Jason.decode!(response_body)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: _body}} ->
        # IO.inspect(body)
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

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        decoded_body = Jason.decode!(response_body)

        {:ok,
         %Planet.Subscriptions.Subscription{
           subscription
           | transaction_history_url: decoded_body["url"]
         }}

      {:ok, %HTTPoison.Response{status_code: status_code, body: _body}} ->
        # IO.inspect(body)
        {:error, "Request failed with status code #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed with reason #{reason}"}
    end
  end
end
