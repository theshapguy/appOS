defmodule PlanetWeb.UserSessionController do
  use PlanetWeb, :controller

  plug Planet.Plug.PageTitle, title: "Login"

  require Logger

  alias Planet.Accounts
  alias PlanetWeb.UserAuth

  def new(conn, _params) do
    conn
    # |> put_session(:authentication_challenge, challenge)
    # |> assign(:authentication_challenge_b64, Base.encode64(challenge.bytes))
    |> render(:new, error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, "Welcome back!")
      # TODO Check If User Active & Organization Active
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> render(:new, error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
