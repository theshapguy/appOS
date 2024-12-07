defmodule Planet.Payments.StripeWhitelist do
  @behaviour Plug

  # require Logger
  # import Plug.Conn
  # import Phoenix.Controller, only: [json: 2]

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _) do
    conn
  end

  # defp webhook_secret_key do
  #   Application.fetch_env!(:planet, :stripe)
  #   |> Keyword.fetch!(:webhook_secret_key)
  # end
end
