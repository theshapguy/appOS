defmodule AppOS.Policies.Subscription do
  @behaviour Bodyguard.Policy
  use AppOS.Policies.Default

  def authorize(:edit, user, _params) do
    require_organization_admin(user)
  end

  def authorize(_action, _user, _params), do: {:error, "unhandled" }
end
