defmodule TheBridgeWeb.AdminLive.Agencies do
  use TheBridgeWeb, :live_view

  alias TheBridge.Agencies

  @impl true
  def mount(_params, _session, socket) do
    agencies = Agencies.list_agencies()

    {:ok,
     socket
     |> assign(:page_title, "Manage Agencies")
     |> assign(:agencies, agencies)}
  end

  @impl true
  def handle_event("verify", %{"id" => id}, socket) do
    agency = Agencies.get_agency!(id)
    {:ok, _agency} = Agencies.verify_agency(agency)
    agencies = Agencies.list_agencies()

    {:noreply,
     socket
     |> put_flash(:info, "#{agency.name} verified.")
     |> assign(:agencies, agencies)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-2xl font-bold">Agencies</h1>

      <div class="overflow-x-auto">
        <table class="table">
          <thead>
            <tr>
              <th>Name</th>
              <th>City</th>
              <th>Verified</th>
              <th>Active</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={agency <- @agencies}>
              <td>{agency.name}</td>
              <td>{agency.city}</td>
              <td>
                <span :if={agency.verified} class="badge badge-success">Yes</span>
                <span :if={!agency.verified} class="badge badge-warning">No</span>
              </td>
              <td>
                <span :if={agency.active} class="badge badge-success">Yes</span>
                <span :if={!agency.active} class="badge badge-error">No</span>
              </td>
              <td>
                <button
                  :if={!agency.verified}
                  phx-click="verify"
                  phx-value-id={agency.id}
                  class="btn btn-success btn-xs"
                >
                  Verify
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
