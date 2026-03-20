defmodule TheBridgeWeb.AgencyLive.Show do
  use TheBridgeWeb, :live_view

  alias TheBridge.{Agencies, Impact}

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user

    unless user.agency_id do
      {:ok, push_navigate(socket, to: ~p"/dashboard")}
    else
      agency = Agencies.get_agency!(user.agency_id)
      stats = Impact.agency_stats(agency.id)

      {:ok,
       socket
       |> assign(:page_title, agency.name)
       |> assign(:agency, agency)
       |> assign(:stats, stats)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-2xl font-bold">{@agency.name}</h1>
      <p :if={@agency.description} class="text-base-content/70">{@agency.description}</p>

      <div class="stats stats-vertical lg:stats-horizontal shadow w-full">
        <div class="stat">
          <div class="stat-title">Clients</div>
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

      <div class="flex gap-4">
        <.link navigate={~p"/agency/clients"} class="btn btn-outline">Manage Clients</.link>
        <.link navigate={~p"/agency/workers"} class="btn btn-outline">Workers</.link>
        <.link navigate={~p"/agency/reports"} class="btn btn-outline">Reports</.link>
      </div>
    </div>
    """
  end

  defp format_cents(cents) when is_integer(cents) do
    :erlang.float_to_binary(cents / 100, decimals: 2)
  end

  defp format_cents(_), do: "0.00"
end
