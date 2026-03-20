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
    <div class="space-y-8">
      <div class="bg-base-200/30 -mx-4 sm:-mx-6 lg:-mx-8 px-4 sm:px-6 lg:px-8 py-16 border-b border-base-300/50 mb-8">
        <div class="max-w-5xl mx-auto">
          <h1 class="text-3xl md:text-4xl font-bold mb-2">{@page_title}</h1>
          <p :if={@agency} class="text-base-content/60">{@agency.description}</p>
          <p :if={!@agency} class="text-base-content/60">See the real impact of community generosity.</p>
        </div>
      </div>

      <div :if={!@agency} class="stats stats-vertical lg:stats-horizontal shadow-sm border border-base-300/50 w-full">
        <div class="stat">
          <div class="stat-figure text-primary"><.icon name="hero-heart" class="size-7" /></div>
          <div class="stat-title">Total Donated</div>
          <div class="stat-value text-primary">${format_cents(@stats.total_donated_cents)}</div>
        </div>
        <div class="stat">
          <div class="stat-figure text-secondary"><.icon name="hero-users" class="size-7" /></div>
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

      <div :if={@agency} class="stats stats-vertical lg:stats-horizontal shadow-sm border border-base-300/50 w-full">
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
        <h2 class="text-xl font-bold mb-4">Needs by Category</h2>
        <div class="grid grid-cols-2 md:grid-cols-5 gap-4">
          <div :for={cat <- @categories} class="bg-base-100 rounded-xl border border-base-300/50 p-4 text-center hover:shadow-md transition-shadow">
            <div class="font-bold text-2xl text-primary">{cat.count}</div>
            <div class="text-sm text-base-content/60 mt-1">{String.capitalize(cat.category)}</div>
            <div class="text-xs text-base-content/40 mt-0.5">${format_cents(cat.funded_cents || 0)} funded</div>
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
