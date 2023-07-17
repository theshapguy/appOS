defmodule AppOSWeb.UserAuthLive do
  use AppOSWeb, :verified_routes

  import Phoenix.LiveView
  import Phoenix.Component

  alias AppOS.Accounts
  alias AppOS.Accounts.User
  alias AppOS.Organizations.Organization

  require Logger

  # def on_mount(:default, _params, _session, socket) do
  #   {:cont, socket}
  # end

  def on_mount(:require_authenticated_user, _params, session, socket) do
    socket = assign_current_user(socket, session)

    case socket.assigns.current_user do
      nil ->
        {:halt,
         socket
         |> put_flash(:error, "You must log in to access this page.")
         |> redirect(to: ~p"/users/log_in")}

      %User{} ->
        {:cont, socket}
    end
  end

  def on_mount(
        :require_same_organization,
        %{"encrypted_user_id" => encrypted_user_id},
        _session,
        socket
      ) do
    user_id = AppOS.Utils.decrypt_string(encrypted_user_id)

    %User{organization_admin?: false, organization: %Organization{id: user_id}} =
      Accounts.get_user!(user_id)

    %User{organization_admin?: true, organization: %Organization{id: current_user_id}} =
      socket.assigns.current_user

    if current_user_id == user_id do
      {:cont, socket}
    else
      # Logger.info("Not Allowed Due To Logged In User And User Id From Different Organization")

      {
        :halt,
        socket
        |> redirect(to: ~p"/users/settings/team/")
      }

      # {:halt,
      # socket
      # |> put_flash(:error, "Not Valid.")
      # |> redirect(to: "~p/users/log_in")}
    end
  end

  defp assign_current_user(socket, session) do
    case session do
      %{"user_token" => user_token} ->
        assign_new(socket, :current_user, fn ->
          Accounts.get_user_by_session_token(user_token)
        end)

      %{} ->
        assign_new(socket, :current_user, fn -> nil end)
    end
  end
end
