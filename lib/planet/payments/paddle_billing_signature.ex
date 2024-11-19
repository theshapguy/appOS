defmodule Planet.Payments.PaddleBillingSignature do
  @behaviour Plug

  require Logger
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _) do
    verify_webhook_signature(conn)
  end

  @type signature_error :: :missing_signature | :invalid_format | :signature_mismatch

  @spec verify_webhook_signature(Plug.Conn.t()) ::
          Plug.Conn.t() | {:error, signature_error()}
  def verify_webhook_signature(conn) do
    headers = Enum.into(conn.req_headers, %{})

    with {:ok, signature} <- get_paddle_signature(headers),
         {:ok, {ts, h1}} <- parse_signature(signature),
         {:ok, _verified} <- verify_signature(conn, ts, h1) do
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

  @spec parse_signature(binary()) :: {:ok, {binary(), binary()}} | {:error, :invalid_format}
  defp parse_signature(signature) do
    with [ts_part, h1_part] <- String.split(signature, ";"),
         [_, ts] <- String.split(ts_part, "="),
         [_, h1] <- String.split(h1_part, "=") do
      {:ok, {ts, h1}}
    else
      _ -> {:error, :invalid_format}
    end
  end

  @spec verify_signature(Plug.Conn.t(), binary(), binary()) ::
          {:ok, boolean()} | {:error, :signature_mismatch}
  defp verify_signature(conn, ts, h1) do
    raw_body = PlanetWeb.CacheBodyReader.get_raw_body(conn)
    signed_payload = "#{ts}:#{raw_body}"

    hmac =
      :crypto.mac(:hmac, :sha256, webhook_secret_key(), signed_payload)
      |> Base.encode16(case: :lower)

    if Plug.Crypto.secure_compare(hmac, h1) do
      {:ok, true}
    else
      {:error, :signature_mismatch}
    end
  end

  defp error_message(:missing_signature), do: "Paddle signature is missing from headers"
  defp error_message(:invalid_format), do: "Invalid signature format"
  defp error_message(:signature_mismatch), do: "Signature verification failed"
  # defp error_message(:too_old), do: "Signature verification failed"

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
