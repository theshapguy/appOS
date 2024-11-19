defmodule Planet.Repo do
  use Ecto.Repo,
    otp_app: :planet,
    adapter: Ecto.Adapters.Postgres

  # adapter: Ecto.Adapters.SQLite3
end
