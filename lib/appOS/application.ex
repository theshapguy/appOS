defmodule AppOS.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      AppOSWeb.Telemetry,
      # Start the Ecto repository
      AppOS.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: AppOS.PubSub},
      # Start Finch
      {Finch, name: AppOS.Finch},
      # Start the Endpoint (http/https)
      AppOSWeb.Endpoint
      # Start a worker by calling: AppOS.Worker.start_link(arg)
      # {AppOS.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AppOS.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AppOSWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
