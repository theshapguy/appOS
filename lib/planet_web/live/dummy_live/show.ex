defmodule PlanetWeb.DummyLive.Show do
  use PlanetWeb, :live_view

  alias Planet.Dummies

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:dummy, Dummies.get_dummy!(id))}
  end

  defp page_title(:show), do: "Show Dummy"
  defp page_title(:edit), do: "Edit Dummy"
end
