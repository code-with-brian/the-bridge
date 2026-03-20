defmodule TheBridgeWeb.AgencyLive.ClientForm do
  use TheBridgeWeb, :live_view

  alias TheBridge.Clients
  alias TheBridge.Clients.Client

  @impl true
  def mount(params, _session, socket) do
    user = socket.assigns.current_scope.user

    {client, changeset, title} =
      if id = params["id"] do
        client = Clients.get_client!(id)
        {client, Clients.change_client(client), "Edit Client"}
      else
        {%Client{}, Clients.change_client(%Client{}, %{agency_id: user.agency_id}), "New Client"}
      end

    {:ok,
     socket
     |> assign(:page_title, title)
     |> assign(:client, client)
     |> assign(:changeset, changeset)
     |> assign(:duplicates, [])}
  end

  @impl true
  def handle_event("validate", %{"client" => client_params}, socket) do
    changeset =
      socket.assigns.client
      |> Clients.change_client(client_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"client" => client_params}, socket) do
    user = socket.assigns.current_scope.user

    client_params =
      Map.merge(client_params, %{
        "agency_id" => user.agency_id,
        "primary_worker_id" => user.id
      })

    save_client(socket, socket.assigns.live_action, client_params)
  end

  defp save_client(socket, :new, params) do
    case Clients.create_client(params) do
      {:ok, client, duplicates} ->
        {:noreply,
         socket
         |> put_flash(
           :warning,
           "Client created. #{length(duplicates)} potential duplicate(s) found."
         )
         |> push_navigate(to: ~p"/agency/clients/#{client.id}")}

      {:ok, client} ->
        {:noreply,
         socket
         |> put_flash(:info, "Client created successfully.")
         |> push_navigate(to: ~p"/agency/clients/#{client.id}")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_client(socket, :edit, params) do
    case Clients.update_client(socket.assigns.client, params) do
      {:ok, client} ->
        {:noreply,
         socket
         |> put_flash(:info, "Client updated successfully.")
         |> push_navigate(to: ~p"/agency/clients/#{client.id}")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto space-y-6">
      <h1 class="text-2xl font-bold">{@page_title}</h1>

      <.form for={@changeset} phx-change="validate" phx-submit="save" class="space-y-4">
        <div class="grid grid-cols-2 gap-4">
          <div class="form-control">
            <label class="label"><span class="label-text">First Name *</span></label>
            <input
              type="text"
              name="client[first_name]"
              value={Ecto.Changeset.get_field(@changeset, :first_name)}
              class="input input-bordered"
              required
            />
          </div>
          <div class="form-control">
            <label class="label"><span class="label-text">Last Name *</span></label>
            <input
              type="text"
              name="client[last_name]"
              value={Ecto.Changeset.get_field(@changeset, :last_name)}
              class="input input-bordered"
              required
            />
          </div>
        </div>

        <div class="form-control">
          <label class="label"><span class="label-text">Public Alias *</span></label>
          <input
            type="text"
            name="client[alias_name]"
            value={Ecto.Changeset.get_field(@changeset, :alias_name)}
            class="input input-bordered"
            required
          />
          <label class="label"><span class="label-text-alt">This name is shown publicly</span></label>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div class="form-control">
            <label class="label"><span class="label-text">Date of Birth</span></label>
            <input
              type="date"
              name="client[date_of_birth]"
              value={Ecto.Changeset.get_field(@changeset, :date_of_birth)}
              class="input input-bordered"
            />
          </div>
          <div class="form-control">
            <label class="label"><span class="label-text">Gender</span></label>
            <input
              type="text"
              name="client[gender]"
              value={Ecto.Changeset.get_field(@changeset, :gender)}
              class="input input-bordered"
            />
          </div>
        </div>

        <div class="form-control">
          <label class="label"><span class="label-text">Housing Status</span></label>
          <select name="client[housing_status]" class="select select-bordered">
            <option value="">Select...</option>
            <option
              :for={status <- Client.housing_statuses()}
              value={status}
              selected={Ecto.Changeset.get_field(@changeset, :housing_status) == status}
            >
              {humanize(status)}
            </option>
          </select>
        </div>

        <div class="form-control">
          <label class="label"><span class="label-text">Story</span></label>
          <textarea name="client[story]" class="textarea textarea-bordered" rows="4">{Ecto.Changeset.get_field(@changeset, :story)}</textarea>
          <label class="label">
            <span class="label-text-alt">Shown publicly — keep it respectful and empowering</span>
          </label>
        </div>

        <div class="form-control">
          <label class="label"><span class="label-text">Private Notes</span></label>
          <textarea name="client[notes]" class="textarea textarea-bordered" rows="3">{Ecto.Changeset.get_field(@changeset, :notes)}</textarea>
          <label class="label">
            <span class="label-text-alt">Only visible to agency workers</span>
          </label>
        </div>

        <div class="form-control">
          <label class="label cursor-pointer justify-start gap-3">
            <input
              type="checkbox"
              name="client[consent_signed]"
              value="true"
              checked={Ecto.Changeset.get_field(@changeset, :consent_signed)}
              class="checkbox"
            />
            <span class="label-text">Client has signed consent form</span>
          </label>
        </div>

        <div class="flex justify-end gap-2">
          <.link navigate={~p"/agency/clients"} class="btn btn-ghost">Cancel</.link>
          <button type="submit" class="btn btn-primary">Save Client</button>
        </div>
      </.form>
    </div>
    """
  end

  defp humanize(str), do: str |> String.replace("_", " ") |> String.capitalize()
end
