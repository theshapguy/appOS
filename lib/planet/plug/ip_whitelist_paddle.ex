defmodule Planet.Plug.PaddleWhitelist do
  @behaviour Plug

  require Logger
  alias Planet.Periodic.PaddleAllowlistIP
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
    remote_ip in PaddleAllowlistIP.get_ips()

    # |> Enum.map(fn ip -> :inet.parse_address(Kernel.to_charlist(ip)) end)
    # |> Enum.map(fn {:ok, ip} -> ip end)

    # Application.fetch_env!(:planet, :paddle)
    # |> Keyword.fetch!(:ip_whitelist)
    # |> Enum.map(fn ip -> :inet.parse_address(Kernel.to_charlist(ip)) end)
    # |> Enum.map(fn {:ok, ip} -> ip end)
  end
end
