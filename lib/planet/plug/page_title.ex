defmodule PlanetWeb.Plugs.PageTitle do
  import Plug.Conn

  def init(title: title) do
    title
  end

  def call(conn, opts) do
    conn |> assign(:page_title, opts)
  end
end
