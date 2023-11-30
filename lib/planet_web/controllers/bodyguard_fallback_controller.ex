defmodule PlanetWeb.BodyguardFallbackController do
  use PlanetWeb, :controller

  def call(conn, {:error, message}) do
    conn
    |> put_status(:forbidden)
    |> put_view(PlanetWeb.ErrorHTML)
    |> render("unauthorized_bodyguard.html", bodyguard_message: message)
    |> halt()
  end
end
