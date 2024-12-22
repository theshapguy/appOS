defmodule PlanetWeb.UserConfirmationController do
  use PlanetWeb, :controller

  alias Planet.Accounts

  plug Planet.Plug.PageTitle, title: "Confirmation"

  plug(:get_user_by_invite_token when action in [:confirm_invite_edit, :confirm_invite_update])

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"user" => %{"email" => email}}) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    conn
    |> put_flash(
      :info,
      "If your email is in our system and it has not been confirmed yet, " <>
        "you will receive an email with instructions shortly."
    )
    |> redirect(to: ~p"/")
  end

  def edit(conn, %{"token" => token}) do
    render(conn, :edit, token: token)
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def update(conn, %{"token" => token}) do
    case Accounts.confirm_user(token) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "User confirmed successfully.")
        |> redirect(to: ~p"/")

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case conn.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            redirect(conn, to: ~p"/")

          %{} ->
            conn
            |> put_flash(:error, "User confirmation link is invalid or it has expired.")
            |> redirect(to: ~p"/")
        end
    end
  end

  def confirm_invite_edit(conn, _params) do
    changeset = Accounts.change_user_registration(conn.assigns.user)
    render(conn, :confirm_invite_edit, changeset: changeset)
  end

  def confirm_invite_update(conn, %{"user" => user_params}) do
    case Accounts.update_user_password(conn.assigns.user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Invite accepted successfully.")
        |> redirect(to: ~p"/users/log_in")

      {:error, changeset} ->
        render(conn, :confirm_invite_edit, changeset: changeset)
    end
  end

  defp get_user_by_invite_token(conn, _opts) do
    %{"token" => token} = conn.params

    if user = Accounts.verify_organization_invite_user_token(token) do
      conn |> assign(:user, user) |> assign(:token, token)
    else
      conn
      |> put_flash(:error, "Invite link is invalid or it has expired.")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
