defmodule PlanetWeb.UserRegistrationController do
  use PlanetWeb, :controller

  plug Planet.Plug.PageTitle, title: "Register"

  alias Planet.Accounts
  alias Planet.Accounts.User
  alias PlanetWeb.UserAuth

  @tz_cookie_key Application.compile_env(:planet, PlanetWeb.Endpoint)
                 |> Keyword.fetch!(:tz_cookie_key)

  def new(conn, params) do
    invite_code = Map.get(params, "invite_code", "")
    changeset = Accounts.change_user_registration(%User{refer_code: invite_code})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    user_params =
      Map.put_new(user_params, "timezone", Map.get(conn.req_cookies, @tz_cookie_key, "Etc/UTC"))

    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        conn
        |> put_flash(:info, "User created successfully.")
        |> UserAuth.log_in_user(user)

      # |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end
end
