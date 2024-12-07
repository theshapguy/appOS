defmodule Planet.Payments.CreemSignature do
  @behaviour Plug

  require Logger
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    verify_webhook_signature(conn)
  end

  @type signature_error ::
          :missing_signature | :signature_mismatch

  @spec verify_webhook_signature(Plug.Conn.t()) :: Plug.Conn.t()
  def verify_webhook_signature(conn) do
    headers = Enum.into(conn.req_headers, %{})

    with {:ok, signature_header} <- get_creem_signature(headers),
         {:ok, timestamp, signatures} <- parse_signature(signature_header),
         {:ok, _verified} <- verify_signature(conn, timestamp, signatures) do
      conn
    else
      {:error, reason} -> halt_conn(conn, 400, error_message(reason))
    end
  end

  @spec get_creem_signature(map()) :: {:ok, binary()} | {:error, :missing_signature}
  defp get_creem_signature(headers) do
    case Map.fetch(headers, "creem-signature") do
      {:ok, signature} when is_binary(signature) -> {:ok, signature}
      _ -> {:error, :missing_signature}
    end
  end

  @spec parse_signature(binary()) ::
          {:ok, binary(), [binary()]} | {:error, :invalid_format}
  defp parse_signature(signature_header) do
    epoch_time_useless = Timex.now() |> Timex.to_unix() |> to_string()

    {:ok, epoch_time_useless, [signature_header]}
  end

  @spec verify_signature(Plug.Conn.t(), binary(), [binary()]) ::
          {:ok, true} | {:error, :signature_mismatch}
  defp verify_signature(conn, _timestamp, signatures) when is_list(signatures) do
    raw_body = PlanetWeb.CacheBodyReader.get_raw_body(conn)
    signed_payload = "#{raw_body}"

    computed_hmac =
      :crypto.mac(:hmac, :sha256, webhook_secret_key(), signed_payload)
      |> Base.encode16(case: :lower)

    if Enum.any?(signatures, fn sig -> Plug.Crypto.secure_compare(computed_hmac, sig) end) do
      {:ok, true}
    else
      {:error, :signature_mismatch}
    end
  end

  @spec error_message(signature_error()) :: binary()
  defp error_message(:missing_signature), do: "Creem-Signature is missing from headers"
  defp error_message(:signature_mismatch), do: "Signature verification failed"

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

  @spec webhook_secret_key() :: binary()
  defp webhook_secret_key do
    Application.fetch_env!(:planet, :creem)
    |> Keyword.fetch!(:webhook_secret_key)
  end
end
