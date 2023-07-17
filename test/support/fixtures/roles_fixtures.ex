defmodule AppOS.RolesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AppOS.Roles` context.
  """

  @doc """
  Generate a role.
  """
  def role_fixture(%AppOS.Organizations.Organization{} = organization, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        active: true,
        name: "some name 55: #{System.unique_integer()}",
        permissions: ["billing-view"]
      })

    {:ok, role} = AppOS.Roles.create_role(organization, attrs)

    role
  end

  @doc """
  Generate a role.
  """
  def user_role_fixture(%AppOS.Accounts.User{} = user, %AppOS.Roles.Role{} = role) do
    {:ok, users_roles} = AppOS.UsersRoles.create_user_role(user, role)

    users_roles
  end
end
