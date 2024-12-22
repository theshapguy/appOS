defmodule Planet.Periodic.PaddleAllowlistIP do
  alias Planet.Payments.Paddle
  use GenServer
  require Logger

  # Fetch every 4 hour
  @interval :timer.minutes(240)

  @sandbox? Application.compile_env(:planet, :payment)[:sandbox?]

  @initial_ip_list [
    "34.232.58.13",
    "34.195.105.136",
    "34.237.3.244",
    "35.155.119.135",
    "52.11.166.252",
    "34.212.5.7"
  ]

  @initial_ip_list_sandbox [
    "34.194.127.46",
    "54.234.237.108",
    "3.208.120.145",
    "44.226.236.210",
    "44.241.183.62",
    "100.20.172.113"
  ]

  # Client API
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_ips do
    GenServer.call(__MODULE__, :get_ips)
  end

  # Server Callbacks
  @dialyzer {:nowarn_function, init: 1}
  def init(_) do
    schedule_fetch()

    case @sandbox? do
      true -> {:ok, @initial_ip_list_sandbox}
      false -> {:ok, @initial_ip_list}
    end
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
    case Paddle.request("webhook_ips") do
      {:ok, response} ->
        ips =
          Map.get(response, "data", %{})
          |> Map.get("ipv4_cidrs", [])
          |> Enum.map(&String.replace(&1, "/32", ""))

        {:ok, ips}

      {:error, error} ->
        Logger.error("Failed to fetch Paddle IPs: #{inspect(error)}")
        {:error, error}
    end
  end

  defp schedule_fetch do
    Process.send_after(self(), :fetch_ips, @interval)
  end
end
