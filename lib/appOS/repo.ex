defmodule AppOS.Repo do
  use Ecto.Repo,
    otp_app: :appOS,
    adapter: Ecto.Adapters.Postgres
end
