defmodule Planet.Payments.PaddleWhitelist do
  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _) do
    if is_whitelisted?(conn) do
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

  def is_whitelisted?(%{remote_ip: remote_ip} = _conn) do
    remote_ip in ip_whitelist()
  end

  def ip_whitelist do
    Application.fetch_env!(:planet, :paddle)
    |> Keyword.fetch!(:ip_whitelist)
    |> Enum.map(fn ip -> :inet.parse_address(Kernel.to_charlist(ip)) end)
    |> Enum.map(fn {:ok, ip} -> ip end)
  end
end
