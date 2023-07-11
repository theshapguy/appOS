defmodule AppOSWeb.BodyguardFallbackController do
  use AppOSWeb, :controller

  def call(conn, {:error, _message}) do
    conn
    |> put_status(:forbidden)
    |> put_view(AppOSWeb.ErrorHTML)
    |> render("unauthorized.html")
  end
end
