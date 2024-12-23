defmodule Planet.Policies.Organization do
  @behaviour Bodyguard.Policy
  use Planet.Policies.Default

  def authorize(:payment, user, _params) do
    require_organization_admin(user)
  end

  def authorize(:edit, _user, _params), do: :ok

  def authorize(_action, _user, _params), do: {:error, "unhandled"}
end
