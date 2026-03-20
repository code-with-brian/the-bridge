defmodule TheBridgeWeb.AgencyLive.ClientIndex do
  use TheBridgeWeb, :live_view

  alias TheBridge.Clients

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    clients = Clients.list_clients_for_agency(user.agency_id)

    {:ok,
     socket
     |> assign(:page_title, "Agency Clients")
     |> assign(:clients, clients)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex justify-between items-center">
        <h1 class="text-2xl font-bold">Clients</h1>
        <.link navigate={~p"/agency/clients/new"} class="btn btn-primary btn-sm">
          Add Client
        </.link>
      </div>

      <div class="overflow-x-auto">
        <table class="table">
          <thead>
            <tr>
              <th>Bridge ID</th>
              <th>Name</th>
              <th>Alias</th>
              <th>Status</th>
              <th>Housing</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={client <- @clients}>
              <td class="font-mono">{client.bridge_id}</td>
              <td>{client.first_name} {client.last_name}</td>
              <td>{client.alias_name}</td>
              <td><span class="badge">{client.status}</span></td>
              <td>{client.housing_status && humanize(client.housing_status)}</td>
              <td class="flex gap-1">
                <.link navigate={~p"/agency/clients/#{client.id}"} class="btn btn-ghost btn-xs">
                  View
                </.link>
                <.link navigate={~p"/agency/clients/#{client.id}/edit"} class="btn btn-ghost btn-xs">
                  Edit
                </.link>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div :if={@clients == []} class="text-center py-12 text-base-content/50">
        No clients yet. <.link navigate={~p"/agency/clients/new"} class="link">Add your first client</.link>.
      </div>
    </div>
    """
  end

  defp humanize(str), do: str |> String.replace("_", " ") |> String.capitalize()
end
