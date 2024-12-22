defmodule Planet.Plug.PaddleClassicSignature do
  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _) do
    with {:ok, signature, message} <- parse(conn),
         :ok <- verify(signature, message),
         #  Parse Passtrhough After Checking Signature
         {:ok, conn2} <- parse_paddle_passthrough(conn) do
      conn2
    else
      {:error, error} ->
        conn
        |> put_status(400)
        |> json(%{
          error: %{
            status: 400,
            message: error
          }
        })
        |> halt()
    end
  end

  defp parse(%{body_params: %{"p_signature" => p_signature}} = conn) do
    signature = Base.decode64!(p_signature)

    message =
      conn.body_params
      |> Map.drop(["p_signature"])
      |> Map.new(fn {k, v} -> {k, to_string(v)} end)
      |> Enum.to_list()
      |> Enum.sort(fn {key1, _value1}, {key2, _value2} -> key1 < key2 end)
      |> PhpSerializer.serialize()

    {:ok, signature, message}
  end

  defp parse(_), do: {:error, "p_signature missing"}

  defp verify(signature, message) do
    [rsa_entry] =
      public_key()
      |> :public_key.pem_decode()

    rsa_public_key = :public_key.pem_entry_decode(rsa_entry)

    case :public_key.verify(message, :sha, signature, rsa_public_key) do
      true -> :ok
      _ -> {:error, "signature is not correct"}
    end
  end

  defp parse_paddle_passthrough(conn) do
    passthrough = Map.get(conn.params, "passthrough", "")

    with passthrough_array <- String.split(passthrough, ";"),
         [_, _, _, _] <- passthrough_array do
      value =
        passthrough_array
        |> Enum.chunk_every(2)
        |> Enum.reduce(%{}, fn [key, val], acc -> Map.put(acc, key, val) end)

      {:ok,
       conn
       |> assign(:paddle_passthrough, value)}
    else
      _ -> {:error, "passthrough data invalid"}
    end
  end

  defp public_key do
    Application.fetch_env!(:planet, :paddle)
    |> Keyword.fetch!(:public_key)
  end
end
