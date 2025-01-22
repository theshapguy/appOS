defmodule Planet.MixProject do
  use Mix.Project

  @version "1.0.0"

  def project do
    [
      app: :planet,
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls, export: "cov"],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
        # "test.run": :test,
        # "test.run.listen": :test,
        # "test.run.ci": :test
      ],
      default_release: :planet,
      releases: [
        planet: [
          include_executables_for: [:unix],
          applications: [planet: :permanent],
          steps: [:assemble, :tar],
          # version: {:from_app, :app}
          # https://hexdocs.pm/mix/Mix.Tasks.Release.html#module-requirements
          # version: @version,
          version: "#{build_name()}"
          # version: "123123" <> "+" <> "darwin_x84",
        ]
      ],
      dialyzer: dialyzer()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Planet.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools
        # :wx,
        # :observer,
        # :mnesia
      ],
      included_applications: [
        :mnesia
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.7.17"},
      {:phoenix_ecto, "~> 4.6"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26.2"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:plug_cowboy, "~> 2.5"},
      # Added phoenix 1.7.17
      {:bandit, "~> 1.5"},
      # Added
      {:httpoison, "~> 2.2.1"},
      {:hashids, "~>2.1.0"},
      {:timex, "~> 3.0"},
      {:bodyguard, "~> 2.4.3"},
      # {:wax_, "~> 0.6.0"},
      {:cbor, "~> 1.0.0"},
      {:mimic, "~> 1.7", only: :test},
      {:excoveralls, "~> 0.18.0", only: :test},
      {:oban, "~> 2.19.0"},
      {:oban_web, "~> 2.11"},
      {:ueberauth, "~> 0.10"},
      {:ueberauth_github, "~> 0.7"},
      {:ueberauth_google, "~> 0.8"},
      {:ecto_sqlite3, "~> 0.17"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": [
        "cmd npm install --prefix ./assets",
        "tailwind.install --if-missing",
        "esbuild.install --if-missing"
      ],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end

  defp build_name() do
    # https://stackoverflow.com/a/52074767
    # https://fiqus.coop/en/2019/07/15/add-git-commit-info-to-your-elixir-phoenix-app/
    target =
      case System.cmd("gcc", ["-dumpmachine"], stderr_to_stdout: true) do
        {target, 0} -> String.trim(target) <> "+"
        _ -> "unknown+"
      end

    commit_sha =
      with {"true\n", 0} <-
             System.cmd("git", ["rev-parse", "--is-inside-work-tree"], stderr_to_stdout: true),
           {commit_sha, 0} <- System.cmd("git", ["rev-parse", "--short", "HEAD"]) do
        String.trim(commit_sha)
      else
        _ -> System.system_time(:second) |> Integer.to_string()
      end

    branch =
      with {"true\n", 0} <-
             System.cmd("git", ["rev-parse", "--is-inside-work-tree"], stderr_to_stdout: true),
           {branch_name, 0} <-
             System.cmd("git", ["rev-parse", "--abbrev-ref", "HEAD"], stderr_to_stdout: true) do
        case String.trim(branch_name) do
          "main" -> ""
          branch -> "-#{branch}"
        end
      else
        _ -> "-not-git"
      end

    @version <> "-" <> target <> branch <> commit_sha
  end

  def user_agent_version() do
    @version
  end

  defp dialyzer do
    [
      plt_add_apps: [
        :mnesia,
        :os_mon,
        :stdlib
      ]
    ]
  end
end
