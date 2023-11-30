defmodule Planet.Policies.Default do
  # https://github.com/thechangelog/changelog.com/blob/96d9e86e3d3602f89f4d653e74916040933226d8/lib/changelog/policies/default.ex
  defmacro __using__(_opts) do
    quote do
      # Permissions Check
      def can?(%Planet.Accounts.User{} = _user) do
        true
      end

      def require_organization_admin(user) do
        case is_organization_admin(user) do
          true -> :ok
          false -> {:error, "Organization Admin Required"}
        end
      end

      defp is_organization_admin(user) do
        user.organization_admin?
      end

      # defoverridable new: 1, create: 1, index: 1, show: 2, edit: 2, update: 2, delete: 2
    end
  end
end
