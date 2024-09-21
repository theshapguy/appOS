defmodule PlanetWeb.UberAuthNController do
  use PlanetWeb, :controller

  alias Planet.UserProviders
  alias PlanetWeb.UserAuth
  alias Planet.Accounts.User
  alias Planet.Accounts

  plug Ueberauth

  # def request(conn, _params) do
  #   # IO.inspect("REQUEST")
  #   Ueberauth.Strategy.Helpers.callback_url(conn) |> IO.inspect()

  #   Phoenix.Controller.redirect(conn, to: Ueberauth.Strategy.Helpers.callback_url(conn))
  # end

  # def callback(%{assigns: %{ueberauth_auth: ueberauth_auth}} = conn, %{"provider" => "tiktok"}) do
  #   IO.inspect(conn)

  #   conn
  #   |> put_flash(:info, "{Tiktok Auth Success}.")
  #   |> redirect(to: ~p"/")
  # end

  def callback(%{assigns: %{ueberauth_auth: ueberauth_auth}} = conn, %{"provider" => provider}) do
    IO.inspect(conn)

    case Accounts.get_user_by_email(ueberauth_auth.info.email) do
      %User{} = user ->
        case UserProviders.upsert_provider(user, ueberauth_auth) do
          {:ok, _} ->
            conn
            |> put_flash(:info, "Welcome back!")
            |> UserAuth.log_in_user(user)

          {:error, %Ecto.Changeset{} = _changeset} ->
            conn
            |> put_flash(:error, "Failed to authenticate using #{String.capitalize(provider)}.")
            |> redirect(to: ~p"/users/log_in")
        end

      nil ->
        case Accounts.register_user(
               %{
                 "email" => ueberauth_auth.info.email,
                 "password" => Planet.Utils.generate_random_string()
               },
               ueberauth_auth
             ) do
          {:ok, user} ->
            {:ok, _} =
              Accounts.deliver_user_confirmation_instructions(
                user,
                &url(~p"/users/confirm/#{&1}")
              )

            conn
            |> put_flash(:info, "User created successfully.")
            |> UserAuth.log_in_user(user)

          {:error, %Ecto.Changeset{} = _changeset} ->
            conn
            |> put_flash(:error, "Failed to authenticate using #{String.capitalize(provider)}.")
            |> redirect(to: ~p"/users/log_in")
        end
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, %{"provider" => provider}) do
    conn
    |> put_flash(:error, "Failed to authenticate with #{String.capitalize(provider)}")
    |> redirect(to: ~p"/users/log_in")
  end
end
