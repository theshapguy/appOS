defmodule AppOSWeb.UserSettingsOrganizationController do
  use AppOSWeb, :controller

  alias AppOS.Organizations
  alias AppOS.Accounts



  plug(:assign_organization_changesets)

  plug Bodyguard.Plug.Authorize,
    policy: AppOS.Policies.Organization,
    action: {Phoenix.Controller, :action_name},
    user: {AppOSWeb.UserAuthorize, :current_user},
    fallback: AppOSWeb.BodyguardFallbackController

  def edit(conn, _params) do
    conn
    |> assign(:organization_admins, Accounts.list_organization_admin(conn.assigns.current_user.organization))
    |> render(:edit)
  end

  def update(conn, %{"action" => "update_name", "organization" => organization_params}) do
    user = conn.assigns.current_user

    case Organizations.update_organization(user.organization, organization_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Updated sucessfully.")
        |> redirect(to: ~p"/users/settings/team")

      {:error, changeset} ->
        render(conn, :edit, organization_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "add_organization_member", "user" => user_params}) do
    case Accounts.register_user_with_organization(
           conn.assigns.current_user.organization,
           user_params
         ) do
      {:ok, user} ->
        Accounts.deliver_user_invite_instructions(
          user,
          conn.assigns.current_user,
          &url(~p"/users/confirm/invite/#{&1}")
        )

        conn
        |> put_flash(:info, "Invited sucessfully.")
        |> redirect(to: ~p"/users/settings/team")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Failed to invite user into your team.")
        |> render(:edit, user_changeset: changeset)
    end
  end

  defp assign_organization_changesets(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(
      :organization_changeset,
      Organizations.change_organization(user.organization)
    )
    |> assign(
      :user_changeset,
      Accounts.change_user_registration_with_organization(%Accounts.User{})
    )
  end
end
