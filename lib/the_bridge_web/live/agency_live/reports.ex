defmodule TheBridgeWeb.AgencyLive.Reports do
  use TheBridgeWeb, :live_view

  alias TheBridge.Impact

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    stats = Impact.agency_stats(user.agency_id)

    {:ok,
     socket
     |> assign(:page_title, "Agency Reports")
     |> assign(:stats, stats)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-2xl font-bold">Reports</h1>

      <div class="stats stats-vertical lg:stats-horizontal shadow w-full">
        <div class="stat">
          <div class="stat-title">Total Clients</div>
          <div class="stat-value">{@stats.total_clients}</div>
        </div>
        <div class="stat">
          <div class="stat-title">Total Needs</div>
          <div class="stat-value">{@stats.total_needs}</div>
        </div>
        <div class="stat">
          <div class="stat-title">Funded</div>
          <div class="stat-value text-primary">${format_cents(@stats.total_funded_cents)}</div>
        </div>
        <div class="stat">
          <div class="stat-title">Fulfilled</div>
          <div class="stat-value text-success">{@stats.fulfilled_count}</div>
        </div>
      </div>
    </div>
    """
  end

  defp format_cents(cents) when is_integer(cents),
    do: :erlang.float_to_binary(cents / 100, decimals: 2)

  defp format_cents(_), do: "0.00"
end
