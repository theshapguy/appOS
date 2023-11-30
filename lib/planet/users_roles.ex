defmodule Planet.UsersRoles do
  import Ecto.Query, warn: false
  alias Planet.Repo

  alias Planet.Accounts.{User, UserRole}
  alias Planet.Accounts

  alias Planet.Organizations.Organization

  alias Planet.Roles.Role

  @doc """
  Creates a UserRole.

  Attaches A Role To A User. Used In Testing To Create User-Role Attachment

  Use this way (put_assoc) When Adding and Removing Role From User, And Not These Method Below
  https://hexdocs.pm/ecto/associations.html#updating-all-associated-records-using-internal-data

  ## Examples

      iex> create_user_role(%{field: value})
      {:ok, %UserRole{}}

      iex> create_user_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_role(%User{} = user, %Role{} = role) do
    %UserRole{}
    |> UserRole.changeset(%{
      "user_id" => user.id,
      "role_id" => role.id
    })
    |> Repo.insert()
  end

  # def list_roles() do
  #   UserRole |> Repo.all()
  # end

  @doc """
  Updates the user name
  """
  def update_user_roles(%User{} = user, roles) do
    user
    |> Ecto.Changeset.change()
    # Running Both Removal And Adding In the Same Pipeline;
    # But Only One `maybe` will Run
    |> maybe_make_user_organization_admin(administrator_role?(roles))
    |> maybe_remove_user_organization_admin(user.organization, removed_admin_role?(user, roles))
    |> Ecto.Changeset.put_assoc(:roles, roles)
    |> Repo.update()
  end

  defp removed_admin_role?(user, updated_roles) when is_list(updated_roles) do
    with true <- user.organization_admin?,
         false <- administrator_role?(updated_roles) do
      # Admin Role Removed Hence Return True
      true
    else
      _ ->
        false
    end
  end

  defp administrator_role?(roles) when is_list(roles) do
    roles
    |> Enum.map(fn item -> item.permissions end)
    # Flatten List, As Permissions Are A List
    |> Enum.concat()
    # Check if List Contains Administrator Permission
    |> Enum.member?(Planet.Roles.Permissions.admin_user_permission())
  end

  defp maybe_make_user_organization_admin(%Ecto.Changeset{} = changeset, true) do
    changeset
    |> Ecto.Changeset.put_change(:organization_admin?, true)
  end

  defp maybe_make_user_organization_admin(%Ecto.Changeset{} = changeset, _) do
    changeset
  end

  defp maybe_remove_user_organization_admin(
         %Ecto.Changeset{} = changeset,
         %Organization{} = organization,
         true
       ) do
    # Make Sure Alteast One Other Admin Exists
    # Do This Check Before Removing Admin
    if Accounts.list_organization_admins(organization, count?: true) > 1 do
      changeset
      |> Ecto.Changeset.put_change(:organization_admin?, false)
    else
      changeset
      |> Ecto.Changeset.add_error(
        :_,
        "Your Team Needs At Least One Administrator Account"
      )
    end
  end

  defp maybe_remove_user_organization_admin(
         %Ecto.Changeset{} = changeset,
         %Organization{} = _organization,
         _
       ) do
    changeset
  end
end
