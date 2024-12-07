defmodule PlanetWeb.PageController do
  use PlanetWeb, :controller

  plug PlanetWeb.Plugs.PageTitle, title: "Home"

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
