defmodule Planet.Plugs.SubscriptionCheck do
  import Plug.Conn
  import Phoenix.Controller

  # Doing this so that we can access the state in the init function,
  # and from outside the module
  def check_allow_unpaid_access() do
    Application.fetch_env!(:planet, :paddle)
    |> Keyword.fetch!(:allow_unpaid_access)
  end

  def init(_default) do
    check_allow_unpaid_access()
  end

  # If Unpaid Access Is Allowed, Can Perform Tasks without Active Status
  def call(conn, true) do
    conn
  end

  def call(conn, false) do
    subscription = conn.assigns.current_user.organization.subscription

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
