defmodule Planet.Periodic.NewRunner do
  @moduledoc """
  Simple example showing the `handle_continue` callback in Erlang/OTP 21+
  """

  use GenServer

  # # simple contrived struct for state - didn't need to be a struct at all
  defstruct prices: %{}

  @doc """
  Start a new instance of the Grocery Cart server
  """
  def start_link(args), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  @doc false
  def init(_args) do
    {:ok, %__MODULE__{}, {:continue, :coin_fetch_init}}
  end

  @doc false
  def handle_continue(:coin_fetch_init, state) do
    # updated_state = %__MODULE__{state | items: ["cheese" | items]}

    schedule_coin_fetch()
    # {:noreply, state, {:continue, :add_milk}}
    {:noreply, state}
  end

  def handle_info(:coin_fetch, state) do
    # price = coin_price()
    schedule_coin_fetch()
    {:noreply, Map.put(state, :btc, "123")}
  end

  defp schedule_coin_fetch do
    Process.send_after(self(), :coin_fetch, 5_000)
  end
end
