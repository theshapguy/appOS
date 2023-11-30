defmodule Planet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PlanetWeb.Telemetry,
      # Start the Ecto repository
      Planet.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Planet.PubSub},
      # Start Finch
      {Finch, name: Planet.Finch},
      # Start the Endpoint (http/https)
      PlanetWeb.Endpoint
      # Start a worker by calling: PlanetWorker.start_link(arg)
      # {PlanetWorker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Planet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PlanetWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
