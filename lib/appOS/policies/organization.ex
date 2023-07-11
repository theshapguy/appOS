defmodule AppOS.Policies.Organization do
  @behaviour Bodyguard.Policy
  use AppOS.Policies.Default

  def authorize(:update, user, _params) do
    require_organization_admin(user)
    # if user.organization_admin?, do: :ok, else: {:error, "Not A Team Admin"}

  end

  def authorize(:edit, _user, _params), do: :ok

  def authorize(_action, _user, _params), do: {:error, "unhandled" }

end
