defmodule AppOSWeb.BodyguardFallbackController do
  use AppOSWeb, :controller

  def call(conn, {:error, message}) do
    conn
    |> put_status(:forbidden)
    |> put_view(AppOSWeb.ErrorHTML)
    |> render("unauthorized_bodyguard.html", bodyguard_message: message)
    |> halt()
  end
end
