defmodule Planet.Payments.Creem do
  alias Planet.HTTPRequest
  alias Planet.Organizations.Organization
  alias Planet.Subscriptions.Subscription
  alias Planet.Accounts.User
  alias Planet.Payments.Plans
  require Logger
  import Planet.Payments.Plans, only: [payment_environment_key: 0]

  defp api_key() do
    # Using fetch env and not compile env due to runtime.ex config being used
    # to set values
    Application.fetch_env!(:planet, :creem) |> Keyword.fetch!(:api_key)
  end

  defp api_endpoint() do
    Application.fetch_env!(:planet, :creem) |> Keyword.fetch!(:api_endpoint)
  end

  # API Calls
  # defp build_url(_id, _opts \\ [])

  defp build_url("sub_" <> _id = subscription_id, opts),
    do:
      "#{api_endpoint()}/subscriptions#{build_query_params(opts ++ [subscription_id: subscription_id])}"

  defp build_url("cust_" <> _id = customer_id, opts),
    do: "#{api_endpoint()}/customers#{build_query_params(opts ++ [customer_id: customer_id])}"

  defp build_url("ch_" <> _id = checkout_id, opts),
    do: "#{api_endpoint()}/checkout#{build_query_params(opts ++ [checkout_id: checkout_id])}"

  defp build_post_url("sub_" <> _id = subscription_id, body, opts) do
    url = "#{api_endpoint()}/subscriptions/#{subscription_id}/cancel#{build_query_params(opts)}"
    {url, body}
  end

  defp build_list_url("cust_" <> _id = customer_id, opts),
    do:
      "#{api_endpoint()}/transactions/search#{build_query_params(opts ++ [customer_id: customer_id, page_size: "5"])}"

  defp build_query_params([]), do: ""
  defp build_query_params(opts), do: "?" <> URI.encode_query(opts)

  defp headers() do
    [
      {"x-api-key", "#{api_key()}"},
      {"Content-Type", "application/json"}
    ]
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: response_body}}) do
    decoded_body = Jason.decode!(response_body)
    {:ok, decoded_body}
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}}) do
    Logger.debug("Request failed with status code #{status_code} and body #{body}")
    {:error, "Request failed with status code #{status_code}"}
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, "Request failed with reason #{reason}"}
  end

  def request(id, opts \\ []) do
    url = build_url(id, opts)

    Logger.debug("Requesting #{url}")

    HTTPRequest.get(url, headers())
    |> handle_response()
  end

  def request_list(id, opts \\ []) do
    url = build_list_url(id, opts)

    Logger.debug("Requesting #{url}")

    HTTPRequest.get(url, headers())
    |> handle_response()
  end

  def request_post(id, body \\ %{}, opts \\ []) do
    {url, body} = build_post_url(id, body, opts)
    body = Jason.encode!(body)

    Logger.debug("Requesting #{url}")

    HTTPRequest.post(url, body, headers())
    |> handle_response()
  end

  def add_customer_details(%User{
        email: email,
        organization: %Organization{
          subscription: %Subscription{
            customer_id: nil
          }
        }
      }) do
    %{email: email}
  end

  # Always user customer id if available
  def add_customer_details(%User{
        email: _email,
        organization: %Organization{
          subscription: %Subscription{
            customer_id: customer_id
          }
        }
      }) do
    %{id: customer_id}
  end

  def checkout_session_url(
        %User{
          id: user_id,
          email: _email,
          organization: %Organization{
            id: organization_id
          }
        } = user,
        price_id
      ) do
    url = "#{api_endpoint()}/checkouts"

    headers = [
      {"accept", "application/json"},
      {"x-api-key", api_key()},
      {"Content-Type", "application/json"}
    ]

    # Manage the URL according to subscription, if lifetime plan ignore body
    # Creem uses product_id as its main identifier, however due to
    # the way our API is structured, and readability using price_id
    %{price_id: ^price_id, product_id: product_id} =
      Plans.variant_by_price_id(:creem, price_id).processors.creem[payment_environment_key()]

    # Request_id used as metadata for the subscription, since order api is not available
    # Redirect URL does not contain metadata, so we use request_id to identify

    # Metadata on a single order like lifetime payment is not available
    # So have to verify using the metadata_as_request_id

    # Webhook will contain the same metadata for single order, but URL redirect will not
    # If Webhook Update Is Late, We Need To Verify Using Request Id

    # UUID is used to ensure uniqueness
    metadata_as_request_id = request_id_metadata_to_string(organization_id, price_id)

    body =
      %{
        "request_id" => metadata_as_request_id,
        "product_id" => product_id,
        "customer" => add_customer_details(user),
        "metadata" => %{
          "user_id" => user_id,
          "organization_id" => organization_id,
          "product_id" => product_id,
          "price_id" => price_id
        },
        "success_url" => Plans.checkout_success_redirect_url(:creem)
      }
      |> Jason.encode!()

    case HTTPRequest.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        decoded_body = Jason.decode!(response_body)

        {:ok, decoded_body}

      {:ok, %HTTPoison.Response{status_code: status_code, body: _body}} ->
        {:error, "Request failed with status code #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed with reason #{reason}"}
    end
  end

  def create_portal_session(%Planet.Subscriptions.Subscription{} = subscription) do
    url = "#{api_endpoint()}/customers/billing"

    headers = [
      {"accept", "application/json"},
      {"x-api-key", api_key()},
      {"Content-Type", "application/json"}
    ]

    body =
      %{
        "customer_id" => subscription.customer_id
      }
      |> Jason.encode!()

    case HTTPRequest.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        decoded_body = Jason.decode!(response_body)

        {:ok,
         %Planet.Subscriptions.Subscription{
           subscription
           | transaction_history_url: decoded_body["customer_portal_link"]
         }}

      {:ok, %HTTPoison.Response{status_code: status_code, body: _body}} ->
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
    |> Kernel.++(["salt=#{api_key()}"])
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

  def request_id_metadata_to_string(organization_id, price_id) do
    "#{organization_id}~~#{price_id}~~#{Ecto.UUID.generate()}"
  end

  def request_id_metadata_to_tuple(request_id) do
    [organization_id, price_id, _uuid] = String.split(request_id, "~~")
    {organization_id, price_id}
  end
end
