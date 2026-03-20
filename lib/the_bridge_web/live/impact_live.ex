defmodule TheBridgeWeb.ImpactLive do
  use TheBridgeWeb, :live_view

  alias TheBridge.{Impact, Agencies}

  @impl true
  def mount(params, _session, socket) do
    {stats, agency, title} =
      if slug = params["agency_slug"] do
        agency = Agencies.get_agency_by_slug!(slug)
        stats = Impact.agency_stats(agency.id)
        {stats, agency, "#{agency.name} — Impact"}
      else
        stats = Impact.platform_stats()
        {stats, nil, "Impact Dashboard"}
      end

    categories = Impact.category_breakdown()

    {:ok,
     socket
     |> assign(:page_title, title)
     |> assign(:stats, stats)
     |> assign(:agency, agency)
     |> assign(:categories, categories)
     |> assign(:fulfillment_rate, Impact.fulfillment_rate())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-2xl font-bold">{@page_title}</h1>

      <div :if={@agency} class="mb-4">
        <p class="text-base-content/70">{@agency.description}</p>
      </div>

      <div :if={!@agency} class="stats stats-vertical lg:stats-horizontal shadow w-full">
        <div class="stat">
          <div class="stat-title">Total Donated</div>
          <div class="stat-value text-primary">${format_cents(@stats.total_donated_cents)}</div>
        </div>
        <div class="stat">
          <div class="stat-title">Donors</div>
          <div class="stat-value">{@stats.total_donors}</div>
        </div>
        <div class="stat">
          <div class="stat-title">People Served</div>
          <div class="stat-value">{@stats.total_clients_served}</div>
        </div>
        <div class="stat">
          <div class="stat-title">Fulfillment Rate</div>
          <div class="stat-value">{@fulfillment_rate}%</div>
        </div>
      </div>

      <div :if={@agency} class="stats stats-vertical lg:stats-horizontal shadow w-full">
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

      <section :if={@categories != []}>
        <h2 class="text-lg font-bold mb-4">Needs by Category</h2>
        <div class="grid grid-cols-2 md:grid-cols-5 gap-3">
          <div :for={cat <- @categories} class="card bg-base-200 p-3 text-center">
            <div class="font-bold text-lg">{cat.count}</div>
            <div class="text-sm text-base-content/70">{String.capitalize(cat.category)}</div>
            <div class="text-xs">${format_cents(cat.funded_cents || 0)} funded</div>
          </div>
        </div>
      </section>
    </div>
    """
  end

  defp format_cents(cents) when is_integer(cents),
    do: :erlang.float_to_binary(cents / 100, decimals: 2)

  defp format_cents(_), do: "0.00"
end
