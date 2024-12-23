# https://hexdocs.pm/mix/Mix.Tasks.Release.html#module-one-off-commands-eval-and-rpc
# _build/dev/rel/app/bin/app eval "Release.Tasks.startup_db_seed()"
defmodule App.ReleaseTasks do
  @moduledoc """
  Used for executing release tasks when run in production without Mix
  installed (exlcuding DB Tasks which is located at release.ex and generated using phx.gen.release)
  """

  @app :planet
  # Notes
  # https://github.com/elixir-ecto/ecto_sql/pull/113
  # https://hexdocs.pm/phoenix/releases.html#ecto-migrations-and-custom-commands

  def priv_directory do
    load_app()

    :code.priv_dir(@app)
    |> List.to_string()
    |> IO.inspect()
  end

  def priv_static_directory do
    load_app()

    List.to_string([:code.priv_dir(@app), "/static"])
    |> IO.inspect()
  end

  defp load_app do
    Application.load(@app)
  end
end
