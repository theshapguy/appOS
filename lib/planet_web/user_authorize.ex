defmodule PlanetWeb.UserAuthorize do
  # Examples
  # https://github.com/OpenFn/Lightning/blob/61a8676632c0e8c845b1b3530ba65b2dbf694e88/lib/lightning/policies/permissions.ex
  # https://github.com/Jazcash/teiserver/blob/fec14784901cb2965d8c1350fe84107c57451877/lib/central_web/controllers/admin/user_controller.ex#L387
  # https://github.com/Bluetab/td-dd/blob/751a3685d3665f097b0f51278093da6a0a64541a/lib/td_dd/data_structures/policy.ex#L6
  # https://www.peterullrich.com/build-a-rap-for-phoenix-part-2
  def current_user(conn) do
    conn.assigns.current_user
  end
end
