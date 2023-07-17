defmodule AppOSWeb.UserSettingsController do
  use AppOSWeb, :controller

  require Logger

  alias AppOS.Accounts
  alias AppOS.UserCredentials
  alias AppOSWeb.UserAuth

  plug(:setup_and_changesets)
  # plug :setup_webauthn_challenge
  plug(:put_webauthn_challenge when action in [:edit, :update])

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

  def update(
        conn,
        %{
          "action" => "add_credential_key",
          "webauthn" => %{
            "attestationObject" => attestation_object_b64,
            "clientDataJSON" => client_data_json,
            "rawID" => raw_id_b64,
            "type" => "public-key",
            "deviceName" => device_name
          }
        }
      ) do
    challenge = get_session(conn, :challenge)
    attestation_object = Base.decode64!(attestation_object_b64)

    with {:ok, {authenticator_data, _result}} <-
           Wax.register(
             attestation_object,
             client_data_json,
             challenge
           ),
         {:ok, _credential} <-
           AppOS.UserCredentials.create_user_credentail(
             conn.assigns.current_user,
             %{
               "credential_id" => raw_id_b64,
               "credential_public_key" =>
                 authenticator_data.attested_credential_data.credential_public_key,
               "aaguid" => Wax.AuthenticatorData.get_aaguid(authenticator_data),
               "nickname" => device_name
             }
           ) do
      conn
      |> put_flash(:info, "Passkey added successfully.")
      |> redirect(to: ~p"/users/settings")
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.debug(changeset)

        conn
        |> put_flash(
          :error,
          "Failed to add passkey. #{AppOS.Utils.traverse_changeset_errors_for_flash(changeset)}"
        )
        |> redirect(to: ~p"/users/settings")

      {:error, _e} = error ->
        Logger.debug("Wax: attestation object validation failed with error #{inspect(error)}")

        # (#{Exception.message(e)})
        conn
        |> put_flash(:error, "Failed to add passkey.")
        |> redirect(to: ~p"/users/settings")
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

  def delete(
        conn,
        %{"credential_id" => credential_id}
      ) do
    case UserCredentials.delete_user_credentail(
           conn.assigns.current_user,
           credential_id
         ) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Passkey sucessfully removed.")
        |> redirect(to: ~p"/users/settings")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to remove PassKey.")
        |> redirect(to: ~p"/users/settings")
    end
  end

  defp setup_and_changesets(conn, _opts) do
    user = conn.assigns.current_user

    %{"#__timezone__#" => timezone} = conn.cookies

    conn
    |> assign(:timezone, timezone)
    |> assign(:email_changeset, Accounts.change_user_email(user))
    |> assign(:password_changeset, Accounts.change_user_password(user))
    |> assign(:name_changeset, Accounts.change_user_fullname(user))
    |> assign(:credentials, UserCredentials.list_user_credentials(conn.assigns.current_user))
  end

  defp put_webauthn_challenge(conn, _opts) do
    case conn.params do
      %{"action" => "add_credential_key"} ->
        # Bypass Adding Challenge
        # If Add Credential Key, Don't Add New Challenge As Challege Gets Updated From the One That Is Sent Before via Edit

        conn

      _ ->
        challenge =
          Wax.new_registration_challenge()

        conn
        |> put_session(:challenge, challenge)
        |> assign(:challenge_b64, Base.encode64(challenge.bytes))
    end
  end
end
