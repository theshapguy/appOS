defmodule PlanetWeb.UserSettingsController do
  use PlanetWeb, :controller

  plug PlanetWeb.Plugs.PageTitle, title: "Settings"

  require Logger

  alias Planet.Accounts
  # alias Planet.UserCredentials
  alias PlanetWeb.UserAuth

  plug(:setup_and_changesets)

  def edit(conn, _params) do
    conn
    |> render(:edit)
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: ~p"/users/settings")

      {:error, changeset} ->
        render(conn, :edit, email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:user_return_to, ~p"/users/settings")
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        render(conn, :edit, password_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_name"} = params) do
    %{"user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.update_user_fullname(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Name updated successfully.")
        |> redirect(to: ~p"/users/settings/")

      {:error, changeset} ->
        render(conn, :edit, name_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_timezone"} = params) do
    %{"user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.update_user_timezone(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Timezone updated successfully.")
        |> redirect(to: ~p"/users/settings/")

      {:error, changeset} ->
        render(conn, :edit, timezone_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: ~p"/users/settings")

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: ~p"/users/settings")
    end
  end

  defp setup_and_changesets(conn, _opts) do
    user = conn.assigns.current_user

    %{"#__timezone__#" => timezone} = conn.cookies

    conn
    |> assign(:timezone, timezone)
    |> assign(:timezone_changeset, Accounts.change_user_timezone(user))
    |> assign(:email_changeset, Accounts.change_user_email(user))
    |> assign(:password_changeset, Accounts.change_user_password(user))
    |> assign(:name_changeset, Accounts.change_user_fullname(user))
    |> assign(:credentials, [])
    # |> assign(:credentials, UserCredentials.list_user_credentials(conn.assigns.current_user))
    |> assign(:page_title, "Settings")
  end
end
