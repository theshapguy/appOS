defmodule PlanetWeb.RoleController do
  use PlanetWeb, :controller

  plug Planet.Plug.PageTitle, title: "Roles"

  alias Planet.Roles
  alias Planet.Roles.Role

  plug :assign_permission_groups

  def new(conn, _params) do
    changeset = Roles.change_role(%Role{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"role" => role_params}) do
    case Roles.create_role(conn.assigns.current_user.organization, role_params) do
      {:ok, role} ->
        conn
        |> put_flash(:info, "[#{role.name}] Role created successfully.")
        |> redirect(to: ~p"/users/settings/team")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    role = Roles.get_role!(conn.assigns.current_user.organization, id)
    changeset = Roles.change_role(role)

    render(conn, "edit.html",
      role: role,
      changeset: changeset,
      selected_permissions: role.permissions
    )
  end

  def update(conn, %{"id" => id, "role" => role_params}) do
    role = Roles.get_role!(conn.assigns.current_user.organization, id)

    case Roles.update_role(
           conn.assigns.current_user.organization,
           role,
           role_params
         ) do
      {:ok, _role} ->
        conn
        |> put_flash(:info, "Role updated successfully.")
        |> redirect(to: ~p"/users/settings/team")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          role: role,
          changeset: changeset,
          selected_permissions: role.permissions
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    role = Roles.get_role!(conn.assigns.current_user.organization, id)

    case Roles.delete_role(role) do
      {:ok, _role} ->
        conn
        |> put_flash(:info, "Role deleted successfully.")
        |> redirect(to: ~p"/users/settings/team")

      {:error,
       %Ecto.Changeset{
         errors: [
           users_roles_role_id_fkey: {message, _}
         ]
       } = changeset} ->
        conn
        |> put_flash(:error, message)
        |> render("edit.html",
          role: role,
          changeset: changeset,
          selected_permissions: role.permissions
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> render("edit.html",
          role: role,
          changeset: changeset,
          selected_permissions: role.permissions
        )
    end
  end

  # def delete(conn, %{"id" => id}) do
  #   dummy = Dummies.get_dummy!(id)
  #   {:ok, _dummy} = Dummies.delete_dummy(dummy)

  #   conn
  #   |> put_flash(:info, "Dummy deleted successfully.")
  #   |> redirect(to: Routes.dummy_path(conn, :index))
  # end

  defp assign_permission_groups(conn, _) do
    conn
    |> assign(:permission_groups, Planet.Roles.Permissions.index())
  end
end
