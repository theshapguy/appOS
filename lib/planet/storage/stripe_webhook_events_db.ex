defmodule Planet.Storage.StripeWebhookEventsDB do
  use GenServer

  # Define the Stripe Webhook Event record
  defmodule StripeWebhookEvent do
    @enforce_keys [:event_id, :event_type, :object_id, :inserted_at]
    defstruct [:event_id, :event_type, :object_id, :inserted_at]
  end

  # Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def store_webhook_event(event_id, event_type, object_id, created_at)
      when is_integer(created_at) do
    GenServer.call(__MODULE__, {:store_event, event_id, event_type, object_id, created_at})
  end

  def get_event(event_id) do
    GenServer.call(__MODULE__, {:get_event, event_id})
  end

  def get_event(event_id, event_type, object_id) do
    GenServer.call(__MODULE__, {:get_event, event_id, event_type, object_id})
  end

  def has_event(event_id, event_type, object_id) do
    case GenServer.call(__MODULE__, {:get_event, event_id, event_type, object_id}) do
      nil -> {:not_found, %{}}
      _ -> {:found, %{}}
    end
  end

  def list_all_events() do
    GenServer.call(__MODULE__, :list_all_events)
  end

  def cleanup_old_events do
    GenServer.call(__MODULE__, :cleanup_events)
  end

  def delete_all_events do
    GenServer.call(__MODULE__, :delete_all_events)
  end

  # Server Callbacks
  @impl true
  def init(_opts) do
    # Create the Mnesia schema
    # This needs to be called before :mnesia.start()
    case :mnesia.create_schema([node()]) do
      :ok -> :ok
      {:error, {_, {:already_exists, _}}} -> :ok
    end

    # Start Mnesia
    :mnesia.start()

    # Create the table with disc copies
    :mnesia.create_table(StripeWebhookEvent,
      attributes: [:event_id, :event_type, :object_id, :inserted_at],
      disc_copies: [node()],
      type: :set
    )

    # Wait for the table to be created
    :mnesia.wait_for_tables([StripeWebhookEvent], 5000)

    # Schedule periodic cleanup every hour
    schedule_cleanup()

    {:ok, %{}}
  end

  @impl true
  def handle_call({:store_event, event_id, event_type, object_id, created_at}, _from, state) do
    # Perform the transaction to insert the Stripe webhook event
    result =
      :mnesia.transaction(fn ->
        :mnesia.write({StripeWebhookEvent, event_id, event_type, object_id, created_at})
      end)

    {:reply, result, state}
  end

  @impl true
  def handle_call({:get_event, event_id}, _from, state) do
    {:atomic, result} =
      :mnesia.transaction(fn ->
        case :mnesia.read({StripeWebhookEvent, event_id}) do
          [{StripeWebhookEvent, id, type, object_id, inserted_at}] ->
            %StripeWebhookEvent{
              event_id: id,
              event_type: type,
              object_id: object_id,
              inserted_at: inserted_at
            }

          [] ->
            nil
        end
      end)

    {:reply, result, state}
  end

  @impl true
  def handle_call({:get_event, event_id, event_type, object_id}, _from, state) do
    {:atomic, result} =
      :mnesia.transaction(fn ->
        case :mnesia.match_object({StripeWebhookEvent, event_id, event_type, object_id, :_}) do
          [{StripeWebhookEvent, evt_id, evt_type, obj_id, inserted_at}] ->
            %StripeWebhookEvent{
              event_id: evt_id,
              event_type: evt_type,
              object_id: obj_id,
              inserted_at: inserted_at
            }

          [] ->
            nil
        end
      end)

    {:reply, result, state}
  end

  @impl true
  def handle_call(:list_all_events, _from, state) do
    result =
      :mnesia.transaction(fn ->
        :mnesia.match_object({StripeWebhookEvent, :_, :_, :_, :_})
      end)
      |> case do
        {:atomic, events} ->
          Enum.map(events, fn {StripeWebhookEvent, id, type, object_id, inserted_at} ->
            %StripeWebhookEvent{
              event_id: id,
              event_type: type,
              object_id: object_id,
              inserted_at: inserted_at
            }
          end)

        _ ->
          []
      end

    {:reply, result, state}
  end

  @impl true
  def handle_call(:cleanup_events, _from, state) do
    # Remove events older than 5 days
    cutoff = System.system_time(:second) - 5 * 24 * 60 * 60
    # cutoff = System.system_time(:second) - 10

    result =
      :mnesia.transaction(fn ->
        :mnesia.select(StripeWebhookEvent, [
          {
            {StripeWebhookEvent, :"$1", :"$2", :"$3", :"$4"},
            [{:<, :"$4", {:const, cutoff}}],
            [:"$$"]
          }
        ])
        |> Enum.each(fn [event_id | _] ->
          :mnesia.delete({StripeWebhookEvent, event_id})
        end)
      end)

    # Reschedule the next cleanup
    schedule_cleanup()

    {:reply, result, state}
  end

  @impl true
  def handle_call(:delete_all_events, _from, state) do
    {:atomic, :ok} = :mnesia.clear_table(StripeWebhookEvent)
    # Table Emptied Hence []
    {:reply, [], state}
  end

  @impl true
  def handle_info(:cleanup_events, state) do
    # Remove events older than 5 days
    cutoff = System.system_time(:second) - 5 * 24 * 60 * 60
    # cutoff = System.system_time(:second) - 10

    _result =
      :mnesia.transaction(fn ->
        :mnesia.select(StripeWebhookEvent, [
          {
            {StripeWebhookEvent, :"$1", :"$2", :"$3", :"$4"},
            [{:<, :"$4", {:const, cutoff}}],
            [:"$$"]
          }
        ])
        |> Enum.each(fn [event_id | _] ->
          :mnesia.delete({StripeWebhookEvent, event_id})
        end)
      end)

    # Reschedule the next cleanup
    schedule_cleanup()

    {:noreply, state}
  end

  # Schedule the cleanup to run every hour to remove older events
  defp schedule_cleanup do
    Process.send_after(self(), :cleanup_events, 60 * 60 * 1000)
  end
end
