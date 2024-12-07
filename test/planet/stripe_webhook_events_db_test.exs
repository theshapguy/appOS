defmodule Planet.Storage.StripeWebhookEventsDBTest do
  use ExUnit.Case, async: false

  alias Planet.Storage.StripeWebhookEventsDB

  setup_all do
    # Start the GenServer
    StripeWebhookEventsDB.start_link()
    :timer.sleep(500)
    :ok
  end

  # setup do
  #   # Ensure a clean state before each test
  #   StripeWebhookEventsDB.delete_all_events()
  #   :ok
  # end

  test "store and retrieve an event by event_id" do
    event_id = "evt_123"
    event_type = "payment_intent.succeeded"
    object_id = "pi_123"
    inserted_at = System.system_time(:second)

    # Store the event
    {:atomic, :ok} =
      StripeWebhookEventsDB.store_webhook_event(event_id, event_type, object_id, inserted_at)

    # Retrieve by event_id only
    event = StripeWebhookEventsDB.get_event(event_id)

    assert event.event_id == event_id
    assert event.event_type == event_type
    assert event.object_id == object_id
    assert event.inserted_at == inserted_at
  end

  test "retrieve an event by event_id, event_type, and object_id" do
    event_id = "evt_456"
    event_type = "charge.refunded"
    object_id = "ch_456"
    inserted_at = System.system_time(:second)

    # Store the event
    {:atomic, :ok} =
      StripeWebhookEventsDB.store_webhook_event(event_id, event_type, object_id, inserted_at)

    # Retrieve using all fields
    event = StripeWebhookEventsDB.get_event(event_id, event_type, object_id)
    assert event.event_id == event_id
    assert event.event_type == event_type
    assert event.object_id == object_id
    assert event.inserted_at == inserted_at
  end

  test "list all events" do
    # Initially, we may already have events from previous tests (if tests run in order)
    events = StripeWebhookEventsDB.list_all_events()

    # Just ensure it returns a list (we can assert length or pattern match events)
    assert is_list(events)
  end

  test "cleanup old events" do
    # Insert an old event by manipulating the inserted_at to be older than 5 days
    old_inserted_at = System.system_time(:second) - 6 * 24 * 60 * 60
    StripeWebhookEventsDB.store_webhook_event("old_evt", "test.type", "obj_old", old_inserted_at)

    # Run cleanup
    StripeWebhookEventsDB.cleanup_old_events()

    # old_evt should no longer be present
    refute StripeWebhookEventsDB.get_event("old_evt")
  end

  test "delete all events" do
    StripeWebhookEventsDB.delete_all_events()
    assert StripeWebhookEventsDB.list_all_events() == []
  end

  test "retrieve non-existent event returns nil" do
    assert StripeWebhookEventsDB.get_event("non_existent_evt") == nil
  end

  test "retrieve non-existent event with type and object_id returns nil" do
    assert StripeWebhookEventsDB.get_event(
             "non_existent_evt",
             "non_existent_type",
             "non_existent_obj"
           ) == nil
  end

  test "store and retrieve multiple events" do
    event_id1 = "evt_789"
    event_type1 = "invoice.created"
    object_id1 = "in_789"
    inserted_at1 = System.system_time(:second)

    event_id2 = "evt_101"
    event_type2 = "customer.created"
    object_id2 = "cus_101"
    inserted_at2 = System.system_time(:second)

    # Store events
    {:atomic, :ok} =
      StripeWebhookEventsDB.store_webhook_event(event_id1, event_type1, object_id1, inserted_at1)

    {:atomic, :ok} =
      StripeWebhookEventsDB.store_webhook_event(event_id2, event_type2, object_id2, inserted_at2)

    # Retrieve events
    event1 = StripeWebhookEventsDB.get_event(event_id1)
    assert event1.event_id == event_id1
    assert event1.event_type == event_type1
    assert event1.object_id == object_id1
    assert event1.inserted_at == inserted_at1

    event2 = StripeWebhookEventsDB.get_event(event_id2)
    assert event2.event_id == event_id2
    assert event2.event_type == event_type2
    assert event2.object_id == object_id2
    assert event2.inserted_at == inserted_at2
  end
end
