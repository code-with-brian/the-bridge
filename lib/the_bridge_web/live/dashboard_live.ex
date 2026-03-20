defmodule TheBridgeWeb.DashboardLive do
  use TheBridgeWeb, :live_view

  alias TheBridge.{Agencies, Clients, Donations, Impact}

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user

    socket =
      case user.role do
        "donor" ->
          impact = Impact.donor_impact(user.id)
          recent = Donations.list_donations_for_donor(user.id) |> Enum.take(5)
          assign(socket, impact: impact, recent_donations: recent)

        role when role in ~w(agency_worker agency_admin) ->
          clients = Clients.list_clients_for_agency(user.agency_id)
          assign(socket, clients: clients)

        "platform_admin" ->
          stats = Impact.platform_stats()
          agencies = Agencies.list_agencies()
          assign(socket, stats: stats, agencies: agencies)

        "vendor" ->
          assign(socket, :page_title, "Vendor Dashboard")

        _ ->
          socket
      end

    {:ok, assign(socket, :page_title, "Dashboard")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-2xl font-bold">Dashboard</h1>

      {render_role_dashboard(assigns)}
    </div>
    """
  end

  defp render_role_dashboard(%{current_scope: %{user: %{role: "donor"}}} = assigns) do
    ~H"""
    <div class="stats stats-vertical lg:stats-horizontal shadow w-full">
      <div class="stat">
        <div class="stat-title">Total Donated</div>
        <div class="stat-value text-primary">${format_cents(@impact.total_donated_cents)}</div>
      </div>
      <div class="stat">
        <div class="stat-title">Donations</div>
        <div class="stat-value">{@impact.donation_count}</div>
      </div>
      <div class="stat">
        <div class="stat-title">People Helped</div>
        <div class="stat-value">{@impact.clients_helped}</div>
      </div>
    </div>

    <div class="mt-6">
      <h2 class="text-lg font-bold mb-4">Recent Donations</h2>
      <div :for={donation <- @recent_donations} class="card bg-base-200 mb-2">
        <div class="card-body py-3">
          <div class="flex justify-between items-center">
            <span>{donation.need.title}</span>
            <span class="font-semibold">${format_cents(donation.amount_cents)}</span>
          </div>
        </div>
      </div>
      <.link navigate={~p"/my-donations"} class="btn btn-outline btn-sm mt-2">
        View All Donations
      </.link>
    </div>
    """
  end

  defp render_role_dashboard(%{current_scope: %{user: %{role: role}}} = assigns)
       when role in ~w(agency_worker agency_admin) do
    ~H"""
    <div class="flex justify-between items-center mb-4">
      <h2 class="text-lg font-bold">Your Agency's Clients</h2>
      <.link navigate={~p"/agency/clients/new"} class="btn btn-primary btn-sm">
        Add Client
      </.link>
    </div>

    <div class="overflow-x-auto">
      <table class="table">
        <thead>
          <tr>
            <th>Bridge ID</th>
            <th>Alias</th>
            <th>Status</th>
            <th>Needs</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={client <- @clients}>
            <td>
              <.link navigate={~p"/agency/clients/#{client.id}"} class="link">
                {client.bridge_id}
              </.link>
            </td>
            <td>{client.alias_name}</td>
            <td><span class="badge">{client.status}</span></td>
            <td>{length(Map.get(client, :needs, []))}</td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  defp render_role_dashboard(%{current_scope: %{user: %{role: "platform_admin"}}} = assigns) do
    ~H"""
    <div class="stats stats-vertical lg:stats-horizontal shadow w-full">
      <div class="stat">
        <div class="stat-title">Total Donated</div>
        <div class="stat-value text-primary">${format_cents(@stats.total_donated_cents)}</div>
      </div>
      <div class="stat">
        <div class="stat-title">Open Needs</div>
        <div class="stat-value">{@stats.needs_open}</div>
      </div>
      <div class="stat">
        <div class="stat-title">Fulfilled</div>
        <div class="stat-value text-success">{@stats.total_needs_fulfilled}</div>
      </div>
    </div>

    <div class="mt-6">
      <h2 class="text-lg font-bold mb-4">Agencies ({length(@agencies)})</h2>
      <div :for={agency <- @agencies} class="card bg-base-200 mb-2">
        <div class="card-body py-3">
          <div class="flex justify-between items-center">
            <span class="font-semibold">{agency.name}</span>
            <div class="flex gap-2">
              <span :if={agency.verified} class="badge badge-success">Verified</span>
              <span :if={!agency.verified} class="badge badge-warning">Unverified</span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp render_role_dashboard(assigns) do
    ~H"""
    <p>Welcome to The Bridge.</p>
    """
  end

  defp format_cents(cents) when is_integer(cents) do
    :erlang.float_to_binary(cents / 100, decimals: 2)
  end

  defp format_cents(_), do: "0.00"
end
