defmodule PlanetWeb.UserSessionController do
  use PlanetWeb, :controller

  require Logger

  alias Planet.UserCredentials
  alias Planet.Accounts
  alias PlanetWeb.UserAuth

  plug :put_webauthn_challenge when action in [:new, :create]

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

  def create(conn, %{
        "webauthn_user" => %{
          "clientDataJSON" => client_data_json,
          "authenticatorData" => authenticator_data_b64,
          "signature" => sig_b64,
          "rawID" => credential_id,
          "type" => "public-key",
          "userHandle" => user_handle
        }
      }) do
    authenticator_data_raw = Base.decode64!(authenticator_data_b64)
    sig_raw = Base.decode64!(sig_b64)

    challenge = get_session(conn, :authentication_challenge)

    credential_id_key_mapping =
      UserCredentials.get_user_credentails!(user_handle, :for_wax_credentials)

    # _credentials_id_aaguid_mapping =
    #   UserCredentials.get_user_credentails!(user_handle, :for_wax_aaguid)

    with {:ok, _} <-
           Wax.authenticate(
             credential_id,
             authenticator_data_raw,
             sig_raw,
             client_data_json,
             challenge,
             credential_id_key_mapping
           ),
         :ignored <-
           check_authenticator_status(
             credential_id,
             # _credentials_id_aaguid_mapping,
             nil,
             challenge
           ),
         %Accounts.User{} = user <-
           Accounts.get_user(user_handle) do
      conn
      |> put_flash(:info, "Welcome back!")
      # TODO Check If User Active & Organization Active
      |> UserAuth.log_in_user(user, %{"remember_me" => true})
    else
      nil ->
        conn
        # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
        # |> render(:new, error_message: "Invalid email or password")
        |> put_flash(
          :error,
          "Invalid email or password"
        )
        |> redirect(to: ~p"/users/log_in")

      {:error, e} ->
        conn
        |> put_flash(
          :error,
          "Authentication failed (error: #{Exception.message(e)}). Try with password."
        )
        |> redirect(to: ~p"/users/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end

  defp put_webauthn_challenge(conn, _opts) do
    case conn.params do
      %{"webauthn_user" => _} ->
        # Bypass Adding Challenge
        # If Add Credential Key, Don't Add New Challenge As Challege Gets Updated From the One That Is Sent Before via Edit

        conn

      _ ->
        challenge =
          Wax.new_authentication_challenge()

        conn
        |> put_session(:authentication_challenge, challenge)
        |> assign(:authentication_challenge_b64, Base.encode64(challenge.bytes))
    end
  end

  defp check_authenticator_status(_credential_id, _cred_id_aaguid_mapping, _challenge) do
    # https://github.com/tanguilp/wax_demo/blob/d6d966d76ddb585c16f7cb1901093e3f82190b40/lib/wax_demo_web/controllers/credential_controller.ex#L163
    # Ignored for Now
    # adce000235bcc60a648b0b25f1f05503
    # Hence attestation none, rather than direct
    # See https://groups.google.com/a/fidoalliance.org/g/fido-dev/c/bEX5GeJN9x0

    :ignored

    # case cred_id_aaguid_mapping[credential_id] do
    #   nil ->
    #     :ok

    #   aaguid ->
    #     case Wax.Metadata.get_by_aaguid(aaguid, challenge) do
    #       {:ok, _} ->
    #         :ok

    #       {:error, _} = error ->
    #         error
    #     end
    # end
  end
end
