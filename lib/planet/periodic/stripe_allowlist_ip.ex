defmodule Planet.Periodic.StripeAllowlistIP do
  alias Planet.Payments.Stripe
  use GenServer
  require Logger

  # Fetch every 4 hour
  @interval :timer.minutes(245)

  @initial_ip_list [
    "3.18.12.63",
    "3.130.192.231",
    "13.235.14.237",
    "13.235.122.149",
    "18.211.135.69",
    "35.154.171.200",
    "52.15.183.38",
    "54.88.130.119",
    "54.88.130.237",
    "54.187.174.169",
    "54.187.205.235",
    "54.187.216.72"
  ]

  # Client API
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_ips do
    GenServer.call(__MODULE__, :get_ips)
  end

  # Server Callbacks
  def init(_) do
    schedule_fetch()
    {:ok, @initial_ip_list}
  end

  def handle_call(:get_ips, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:fetch_ips, state) do
    new_state =
      case fetch_ips() do
        {:ok, []} ->
          # Just in case if api returns empty
          state

        {:ok, ips} ->
          ips

        {:error, _} ->
          # If Any Error, Don't Deviate From The Loaded State
          state
      end

    schedule_fetch()
    {:noreply, new_state}
  end

  defp fetch_ips do
    case Stripe.request("webhook_ips") do
      {:ok, response} ->
        {:ok, Map.get(response, "WEBHOOKS", [])}

      {:error, error} ->
        Logger.error("Failed to fetch Stripe IPs: #{inspect(error)}")
        {:error, error}
    end
  end

  defp schedule_fetch do
    Process.send_after(self(), :fetch_ips, @interval)
  end
end
