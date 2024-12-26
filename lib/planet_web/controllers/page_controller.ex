defmodule PlanetWeb.PageController do
  alias Planet.Payments.Plans
  use PlanetWeb, :controller

  plug Planet.Plug.PageTitle, title: "Home"

  @hash System.cmd("git", ["rev-parse", "HEAD"]) |> elem(0) |> String.trim()

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home)
  end

  def app_home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :app_home, put_layout: :app_dashboard)
  end

  def plans(conn, params) do
    promo_code_param = params |> Map.get("discount")
    coupon = Plans.coupon(promo_code_param)

    conn
    |> render(:plans,
      subscription_plans:
        Planet.Payments.Plans.list(
          nil,
          !Application.get_env(:planet, :payment)[:allow_free_plan_access]
        ),
      subscription_plans_without_free: Planet.Payments.Plans.list(),
      discount_code: coupon || Plans.coupons() |> Enum.at(0)
    )
  end

  def privacy(conn, _params) do
    conn
    |> render(:privacy)
  end

  def terms(conn, _params) do
    conn
    |> render(:terms)
  end

  def refund(conn, _params) do
    conn
    |> render(:refund)
  end

  def version(conn, _params) do
    conn
    |> text(@hash)
  end

  def health(conn, _params) do
    conn
    |> text("ok: i am alive")
  end
end
