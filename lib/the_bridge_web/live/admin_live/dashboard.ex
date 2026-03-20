defmodule TheBridgeWeb.AdminLive.Dashboard do
  use TheBridgeWeb, :live_view

  alias TheBridge.Impact

  @impl true
  def mount(_params, _session, socket) do
    stats = Impact.platform_stats()

    {:ok,
     socket
     |> assign(:page_title, "Admin Dashboard")
     |> assign(:stats, stats)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-2xl font-bold">Admin Dashboard</h1>

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
          <div class="stat-title">People Served</div>
          <div class="stat-value">{@stats.total_clients_served}</div>
        </div>
        <div class="stat">
          <div class="stat-title">Needs Fulfilled</div>
          <div class="stat-value text-success">{@stats.total_needs_fulfilled}</div>
        </div>
      </div>

      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <.link navigate={~p"/admin/agencies"} class="btn btn-outline">Agencies</.link>
        <.link navigate={~p"/admin/vendors"} class="btn btn-outline">Vendors</.link>
        <.link navigate={~p"/admin/users"} class="btn btn-outline">Users</.link>
        <.link navigate={~p"/admin/audit-log"} class="btn btn-outline">Audit Log</.link>
      </div>
    </div>
    """
  end

  defp format_cents(cents) when is_integer(cents),
    do: :erlang.float_to_binary(cents / 100, decimals: 2)

  defp format_cents(_), do: "0.00"
end
