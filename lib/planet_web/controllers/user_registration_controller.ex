defmodule PlanetWeb.UserRegistrationController do
  use PlanetWeb, :controller

  plug PlanetWeb.Plugs.PageTitle, title: "Register"

  alias Planet.Accounts
  alias Planet.Accounts.User
  alias PlanetWeb.UserAuth

  def new(conn, params) do
    invite_code = Map.get(params, "invite_code", "")
    changeset = Accounts.change_user_registration(%User{refer_code: invite_code})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    # redirect_url =
    #   case Planet.Plugs.SubscriptionCheck.check_allow_unpaid_access() do
    #     false -> %{"redirect_url" => ~p"/users/billing/signup"}
    #     true -> %{}
    #   end

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
