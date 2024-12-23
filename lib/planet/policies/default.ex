defmodule Planet.Policies.Default do
  alias Planet.Accounts.User

  # https://github.com/thechangelog/changelog.com/blob/96d9e86e3d3602f89f4d653e74916040933226d8/lib/changelog/policies/default.ex
  defmacro __using__(_opts) do
    quote do
      def require_organization_admin(%User{} = user) do
        case user.organization_admin? do
          true -> :ok
          false -> {:error, "Organization Admin Required"}
        end
      end

      def has_role(
            %User{
              roles: user_roles
            },
            role_to_check
          ) do
        # Not using pattern matching here because of code readability
        case user_roles do
          nil -> false
          [] -> false
          _ -> role_to_check in Enum.flat_map(user_roles, & &1.permissions)
        end
      end

      def can?(%User{} = user, role) do
        has_role(user, role)
      end

      # defoverridable new: 1, create: 1, index: 1, show: 2, edit: 2, update: 2, delete: 2
    end
  end
end
