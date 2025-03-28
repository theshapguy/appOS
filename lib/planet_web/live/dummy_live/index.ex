defmodule PlanetWeb.DummyLive.Index do
  use PlanetWeb, :live_view

  alias Planet.Dummies
  alias Planet.Dummies.Dummy

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :dummies, Dummies.list_dummies())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Dummy")
    |> assign(:dummy, Dummies.get_dummy!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Dummy")
    |> assign(:dummy, %Dummy{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Dummies")
    |> assign(:dummy, nil)
  end

  @impl true
  def handle_info({PlanetWeb.DummyLive.FormComponent, {:saved, dummy}}, socket) do
    {:noreply, stream_insert(socket, :dummies, dummy)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    dummy = Dummies.get_dummy!(id)
    {:ok, _} = Dummies.delete_dummy(dummy)

    {:noreply, stream_delete(socket, :dummies, dummy)}
  end
end
