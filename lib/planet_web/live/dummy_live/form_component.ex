defmodule PlanetWeb.DummyLive.FormComponent do
  use PlanetWeb, :live_component

  alias Planet.Dummies

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage dummy records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="dummy-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:age]} type="number" label="Age" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Dummy</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{dummy: dummy} = assigns, socket) do
    changeset = Dummies.change_dummy(dummy)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"dummy" => dummy_params}, socket) do
    changeset =
      socket.assigns.dummy
      |> Dummies.change_dummy(dummy_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"dummy" => dummy_params}, socket) do
    save_dummy(socket, socket.assigns.action, dummy_params)
  end

  defp save_dummy(socket, :edit, dummy_params) do
    case Dummies.update_dummy(socket.assigns.dummy, dummy_params) do
      {:ok, dummy} ->
        notify_parent({:saved, dummy})

        {:noreply,
         socket
         |> put_flash(:info, "Dummy updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_dummy(socket, :new, dummy_params) do
    case Dummies.create_dummy(dummy_params) do
      {:ok, dummy} ->
        notify_parent({:saved, dummy})

        {:noreply,
         socket
         |> put_flash(:info, "Dummy created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
