defmodule Planet.Periodic.Runner do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(state) do
    IO.inspect(state)
    schedule_coin_fetch()
    {:ok, state}
  end

  def handle_info(:coin_fetch, state) do
    # price = coin_price()
    IO.inspect("123")
    # IO.inspect("Current Bitcoin price is $#{price}")
    schedule_coin_fetch()
    {:noreply, Map.put(state, :btc, "123")}
  end

  # defp coin_price do
  #   "https://api.coincap.io/v2/assets/bitcoin"
  #   |> HTTPoison.get!()
  #   |> Map.get(:body)
  #   |> Jason.decode!()
  #   |> Map.get("data")
  # end

  defp schedule_coin_fetch do
    Process.send_after(self(), :coin_fetch, 5_000)
  end
end
