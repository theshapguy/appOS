defmodule Planet.Policies.Subscription do
  @behaviour Bodyguard.Policy
  use Planet.Policies.Default

  def authorize(:edit, user, _params) do
    require_organization_admin(user)
    :ok
  end

  # def authorize(:edit, _user, _params), do: :ok

  def authorize(_action, _user, _params), do: {:error, "unhandled"}
end
