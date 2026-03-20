defmodule TheBridgeWeb.AdminLive.Reports do
  use TheBridgeWeb, :live_view

  alias TheBridge.Impact

  @impl true
  def mount(_params, _session, socket) do
    stats = Impact.platform_stats()
    categories = Impact.category_breakdown()

    {:ok,
     socket
     |> assign(:page_title, "Platform Reports")
     |> assign(:stats, stats)
     |> assign(:categories, categories)
     |> assign(:fulfillment_rate, Impact.fulfillment_rate())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-2xl font-bold">Platform Reports</h1>

      <div class="stats stats-vertical lg:stats-horizontal shadow w-full">
        <div class="stat">
          <div class="stat-title">Total Donated</div>
          <div class="stat-value text-primary">${format_cents(@stats.total_donated_cents)}</div>
        </div>
        <div class="stat">
          <div class="stat-title">Fulfillment Rate</div>
          <div class="stat-value">{@fulfillment_rate}%</div>
        </div>
        <div class="stat">
          <div class="stat-title">Open Needs</div>
          <div class="stat-value">{@stats.needs_open}</div>
        </div>
      </div>

      <section :if={@categories != []}>
        <h2 class="text-lg font-bold mb-4">By Category</h2>
        <div class="overflow-x-auto">
          <table class="table">
            <thead>
              <tr>
                <th>Category</th>
                <th>Needs</th>
                <th>Funded</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={cat <- @categories}>
                <td>{String.capitalize(cat.category)}</td>
                <td>{cat.count}</td>
                <td>${format_cents(cat.funded_cents || 0)}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
    </div>
    """
  end

  defp format_cents(cents) when is_integer(cents),
    do: :erlang.float_to_binary(cents / 100, decimals: 2)

  defp format_cents(_), do: "0.00"
end
