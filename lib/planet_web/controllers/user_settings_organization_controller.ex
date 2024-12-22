defmodule PlanetWeb.UserSettingsOrganizationController do
  use PlanetWeb, :controller

  plug Planet.Plug.PageTitle, title: "Team"

  alias Planet.Organizations
  alias Planet.Accounts
  alias Planet.Roles
  alias Planet.UsersRoles
  alias Planet.Roles.Role

  import Planet.Utils

  plug(:assign_changesets)

  plug Bodyguard.Plug.Authorize,
    policy: Planet.Policies.Organization,
    action: {Phoenix.Controller, :action_name},
    user: {PlanetWeb.UserAuthorize, :current_user},
    fallback: PlanetWeb.BodyguardFallbackController

  def edit(conn, _params) do
    render(conn, :edit)
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

  def update(conn, %{
        "action" => "add_organization_member",
        "user" => user_params,
        "role_id" => role_id
      }) do
    %Role{} = role = Roles.get_role!(conn.assigns.current_user.organization, role_id)

    case Accounts.register_user_with_organization(
           conn.assigns.current_user.organization,
           role,
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

  def update(
        conn,
        %{
          "action" => "update_role",
          "role_id" => role_id,
          "user_id" => user_id
        }
      ) do
    current_organization = conn.assigns.current_user.organization

    user = Accounts.get_user!(current_organization, user_id)
    role = Roles.get_role!(current_organization, role_id, ignore_editable: true)

    case UsersRoles.update_user_roles(user, [role]) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Role for [#{user.email}] updated sucessfully.")
        |> redirect(to: ~p"/users/settings/team#manage-team-list-#{user.id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(
          :error,
          "Failed to update role for [#{user.email}]. #{traverse_changeset_errors_for_flash(changeset)}"
        )
        |> redirect(to: ~p"/users/settings/team#manage-team-list-#{user.id}")
    end

    # case Organizations.update_organization(user.organization, organization_params) do
    #   {:ok, _} ->
    #     conn
    #     |> put_flash(:info, "Updated sucessfully.")
    #     |> redirect(to: ~p"/users/settings/team")

    #   {:error, changeset} ->
    #     render(conn, :edit, organization_changeset: changeset)
    # end
  end

  defp assign_changesets(conn, _opts) do
    user =
      conn.assigns.current_user

    conn
    |> assign(
      :organization_changeset,
      Organizations.change_organization(user.organization)
    )
    |> assign(
      :user_changeset,
      Accounts.change_user_registration_with_organization(%Accounts.User{})
    )
    |> assign(
      :organization_members,
      Accounts.list_organization_members(conn.assigns.current_user.organization)
    )
    |> assign(
      :roles,
      Roles.list_roles(conn.assigns.current_user.organization)
    )
  end
end
