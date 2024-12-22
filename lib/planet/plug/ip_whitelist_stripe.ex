defmodule Planet.Plug.StripeWhitelist do
  @behaviour Plug

  require Logger
  alias Planet.Periodic.StripeAllowlistIP
  alias Planet.Utils.RemoteIP

  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _) do
    if RemoteIP.get(conn) |> is_whitelisted?() do
      conn
    else
      Logger.error("Host not allowed: #{__MODULE__}")

      conn
      |> put_status(403)
      |> json(%{
        error: %{
          status: 403,
          message: "host not allowed"
        }
      })
      |> halt()
    end
  end

  defp is_whitelisted?(remote_ip) do
    remote_ip in ip_whitelist()
  end

  defp ip_whitelist do
    StripeAllowlistIP.get_ips()
    # |> Enum.map(fn ip -> :inet.parse_address(Kernel.to_charlist(ip)) end)
    # |> Enum.map(fn {:ok, ip} -> ip end)
  end
end
