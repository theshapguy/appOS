defmodule AppOSWeb.UserRegistrationController do
  use AppOSWeb, :controller

  alias AppOS.Accounts
  alias AppOS.Accounts.User
  alias AppOSWeb.UserAuth

  def new(conn, params) do
    refer_code = Map.get(params, "invite_code", "")
    changeset = Accounts.change_user_registration(%User{})
    render(conn, :new, changeset: changeset, refer_code: refer_code)
  end

  def create(conn, %{"user" => user_params} = params) do
    refer_code = Map.get(params, "invite_code", "")

    case Accounts.register_user(user_params, refer_code) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        conn
        |> put_flash(:info, "User created successfully.")
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset, refer_code: refer_code)
    end
  end
end
