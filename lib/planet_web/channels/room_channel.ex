defmodule PlanetWeb.RoomChannel do
  use PlanetWeb, :channel

  @impl true
  def join("room:lobby", _payload, socket) do
    {:ok, socket}
    # if authorized?(1) do

    # else
    #   {:error, %{reason: "unauthorized"}}
    # end
  end

  def join("room:" <> _room_id, _payload, socket) do
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  # defp authorized?(payload) do
  #   if payload == 1, do: true, else: false
  # end
end
