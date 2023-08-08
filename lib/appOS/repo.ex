defmodule AppOS.Repo do
  use Ecto.Repo,
    otp_app: :appos,
    adapter: Ecto.Adapters.Postgres
end
