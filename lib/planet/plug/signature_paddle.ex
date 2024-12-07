defmodule Planet.Payments.PaddleSignature do
  @behaviour Plug

  require Logger
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  # Default is 5 for PaddleSDK, but using 300
  @tolerance_in_seconds 300

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    verify_webhook_signature(conn)
  end

  @type signature_error ::
          :missing_signature | :invalid_format | :signature_mismatch | :timestamp_invalid

  @spec verify_webhook_signature(Plug.Conn.t()) :: Plug.Conn.t()
  def verify_webhook_signature(conn) do
    headers = Enum.into(conn.req_headers, %{})

    with {:ok, signature_header} <- get_paddle_signature(headers),
         {:ok, timestamp, signatures} <- parse_signature(signature_header),
         {:ok, _timestamp_ok} <- verify_timestamp(timestamp),
         {:ok, _verified} <- verify_signature(conn, timestamp, signatures) do
      conn
    else
      {:error, reason} -> halt_conn(conn, 400, error_message(reason))
    end
  end

  @spec get_paddle_signature(map()) :: {:ok, binary()} | {:error, :missing_signature}
  defp get_paddle_signature(headers) do
    case Map.fetch(headers, "paddle-signature") do
      {:ok, signature} when is_binary(signature) -> {:ok, signature}
      _ -> {:error, :missing_signature}
    end
  end

  @spec parse_signature(binary()) ::
          {:ok, binary(), [binary()]} | {:error, :invalid_format}
  defp parse_signature(signature_header) do
    parts = String.split(signature_header, ";")
    timestamp_part = Enum.find(parts, fn part -> String.starts_with?(part, "ts=") end)
    signature_parts = Enum.filter(parts, fn part -> String.starts_with?(part, "h1=") end)

    with "ts=" <> timestamp <- timestamp_part,
         [_ | _] = signatures <- signature_parts do
      h1_signatures = Enum.map(signatures, fn "h1=" <> sig -> sig end)
      {:ok, timestamp, h1_signatures}
    else
      _ -> {:error, :invalid_format}
    end
  end

  @spec verify_signature(Plug.Conn.t(), binary(), [binary()]) ::
          {:ok, true} | {:error, :signature_mismatch}
  defp verify_signature(conn, timestamp, signatures) when is_list(signatures) do
    raw_body = PlanetWeb.CacheBodyReader.get_raw_body(conn)
    signed_payload = "#{timestamp}:#{raw_body}"

    computed_hmac =
      :crypto.mac(:hmac, :sha256, webhook_secret_key(), signed_payload)
      |> Base.encode16(case: :lower)

    if Enum.any?(signatures, fn sig -> Plug.Crypto.secure_compare(computed_hmac, sig) end) do
      {:ok, true}
    else
      {:error, :signature_mismatch}
    end
  end

  # Add timestamp verification
  @spec verify_timestamp(binary()) :: {:ok, true} | {:error, :timestamp_invalid}
  defp verify_timestamp(timestamp) do
    case Integer.parse(timestamp) do
      {timestamp_int, ""} ->
        now = System.system_time(:second)
        diff = abs(now - timestamp_int)

        if diff <= @tolerance_in_seconds do
          {:ok, true}
        else
          {:error, :timestamp_invalid}
        end

      _ ->
        {:error, :timestamp_invalid}
    end
  end

  @spec error_message(signature_error()) :: binary()
  defp error_message(:missing_signature), do: "Paddle-Signature is missing from headers"
  defp error_message(:invalid_format), do: "Invalid signature format"
  defp error_message(:signature_mismatch), do: "Signature verification failed"
  defp error_message(:timestamp_invalid), do: "Timestamp is too old or invalid"

  @spec halt_conn(Plug.Conn.t(), integer(), binary()) :: Plug.Conn.t()
  defp halt_conn(conn, status, message) do
    conn
    |> put_status(status)
    |> json(%{
      error: %{
        status: status,
        message: message
      }
    })
    |> halt()
  end

  defp webhook_secret_key do
    Application.fetch_env!(:planet, :paddle)
    |> Keyword.fetch!(:webhook_secret_key)
  end
end
