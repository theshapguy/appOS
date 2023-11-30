defmodule Planet.Roles.Permissions do
  @admin_permission "administrator-admin"
  @normal_permission ["settings-view", "settings-update"]

  @doc """
  List of all available permissions within our application

  → [Permission Group]
      → [Permission]
          → Name (To Display To Users On Checkbox)
          → Slug (To Save To DB And Make Permission Check Against This String)
          → Descriptor (Details About The Permission)
  """
  def index do
    [
      # This is commented out becuase admin is set using user struct and not this permission,
      # and not by checking the box

      # @admin_permission is used in slug list so that when that permission is there,
      # user.organization_admin? is set

      # %{
      #   name: "Administrator",
      #   permissions: [
      #     %{
      #       name: "Account Administrator",
      #       slug: @admin_permission,
      #       descriptor: "Allows users to access all parts of the application"
      #     }
      #   ]
      # },
      %{
        name: "Billing",
        permissions: [
          %{
            name: "View",
            slug: "billing-view",
            descriptor: "Allows users to view the billing page"
          },
          %{
            name: "Update",
            slug: "billing-update",
            descriptor: "Allows users to update billing"
          }
        ]
      },
      %{
        name: "Settings",
        permissions: [
          %{
            name: "View",
            slug: "settings-view",
            descriptor: "Allows users to view the settings page"
          },
          %{
            name: "Update",
            slug: "settings-update",
            descriptor: "Allows users to update their name, email and password"
          }
        ]
      }
    ]
  end

  @doc """
  List of permissions only
  """
  def simple_list() do
    index()
    |> Enum.map(fn item -> item.permissions end)
    |> Enum.concat()
  end

  @doc """
  List of permissions only
  """
  def simple_slug_list() do
    index()
    |> Enum.map(fn item -> item.permissions end)
    |> Enum.concat()
    |> Enum.map(fn item -> item.slug end)
    # Add Administrator Permission
    |> Enum.concat([@admin_permission])
  end

  def admin_user_permission() do
    @admin_permission
  end

  def normal_user_default_permission_list() do
    @normal_permission
  end
end
