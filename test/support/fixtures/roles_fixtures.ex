defmodule Planet.RolesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PlanetRoles` context.
  """

  @doc """
  Generate a role.
  """
  def role_fixture(%Planet.Organizations.Organization{} = organization, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        active: true,
        name: "some name 55: #{System.unique_integer()}",
        permissions: ["billing-view"]
      })

    {:ok, role} = Planet.Roles.create_role(organization, attrs)

    role
  end

  @doc """
  Generate a role.
  """
  def user_role_fixture(%Planet.Accounts.User{} = user, %Planet.Roles.Role{} = role) do
    {:ok, users_roles} = Planet.UsersRoles.create_user_role(user, role)

    users_roles
  end
end
