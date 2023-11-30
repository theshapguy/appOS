defmodule PlanetWeb.TemplateLive.Index do
  use PlanetWeb, :live_view

  alias Planet.Templates
  alias Planet.Templates.Template

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :templates, Templates.list_templates())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Template")
    |> assign(:template, Templates.get_template!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Template")
    |> assign(:template, %Template{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Templates")
    |> assign(:template, nil)
  end

  @impl true
  def handle_info({PlanetWeb.TemplateLive.FormComponent, {:saved, template}}, socket) do
    {:noreply, stream_insert(socket, :templates, template)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    template = Templates.get_template!(id)
    {:ok, _} = Templates.delete_template(template)

    {:noreply, stream_delete(socket, :templates, template)}
  end
end
