defmodule Planet.Plugs.SubscriptionCheck do
  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]

  @impl true
  def init(opts) do
    opts
  end

  @impl true
  def call(conn, _opts) do
    subscription = conn.assigns.current_user.organization.subscription

    # Allow Access To Home

    case subscription.status do
      :active ->
        conn

      _ ->
        conn
        |> redirect(to: "/users/billing/signup")
        |> halt()
    end
  end
end
