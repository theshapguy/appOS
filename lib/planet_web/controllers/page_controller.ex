defmodule PlanetWeb.PageController do
  use PlanetWeb, :controller

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
end
