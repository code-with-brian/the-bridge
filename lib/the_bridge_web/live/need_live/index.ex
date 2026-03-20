defmodule TheBridgeWeb.NeedLive.Index do
  use TheBridgeWeb, :live_view

  alias TheBridge.Clients
  alias TheBridge.Clients.Need

  @impl true
  def mount(_params, _session, socket) do
    needs = Clients.list_needs()

    {:ok,
     socket
     |> assign(:page_title, "Browse Needs")
     |> assign(:needs, needs)
     |> assign(:category_filter, nil)}
  end

  @impl true
  def handle_event("filter", %{"category" => ""}, socket) do
    {:noreply, assign(socket, needs: Clients.list_needs(), category_filter: nil)}
  end

  def handle_event("filter", %{"category" => category}, socket) do
    needs =
      Clients.list_needs()
      |> Enum.filter(&(&1.category == category))

    {:noreply, assign(socket, needs: needs, category_filter: category)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="bg-base-200/30 -mx-4 sm:-mx-6 lg:-mx-8 px-4 sm:px-6 lg:px-8 py-16 border-b border-base-300/50 mb-8">
        <div class="max-w-5xl mx-auto">
          <h1 class="text-3xl md:text-4xl font-bold mb-2">Open Needs</h1>
          <p class="text-base-content/60">Browse verified needs and make a direct impact.</p>
        </div>
      </div>

      <div class="max-w-6xl mx-auto space-y-6">
        <div class="sticky top-16 z-40 bg-base-100/95 backdrop-blur-sm border-b border-base-300/50 -mx-4 sm:-mx-6 lg:-mx-8 px-4 sm:px-6 lg:px-8 py-3">
          <div class="flex gap-2 flex-wrap">
            <button
              phx-click="filter"
              phx-value-category=""
              class={["btn btn-sm rounded-full", (!@category_filter && "btn-primary") || "btn-outline border-base-300/60"]}
            >
              All
            </button>
            <button
              :for={cat <- Need.categories()}
              phx-click="filter"
              phx-value-category={cat}
              class={["btn btn-sm rounded-full", (@category_filter == cat && "btn-primary") || "btn-outline border-base-300/60"]}
            >
              {String.capitalize(cat)}
            </button>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div :for={need <- @needs} class="card bg-base-100 border border-base-300/60 hover:border-primary/30 hover:shadow-lg transition-all duration-300 hover:-translate-y-1">
            <div class="card-body">
              <div class="flex gap-2">
                <span class="badge bg-primary/10 text-primary border-0 text-xs">{need.category}</span>
                <span :if={need.priority == "urgent"} class="badge badge-error text-xs">Urgent</span>
                <span :if={need.priority == "high"} class="badge badge-warning text-xs">High</span>
              </div>
              <h3 class="card-title text-base">{need.title}</h3>
              <p class="text-sm text-base-content/60">{need.client.alias_name}</p>
              <div class="mt-3">
                <div class="flex justify-between text-sm mb-1.5">
                  <span class="font-bold">${format_cents(need.funded_cents)}</span>
                  <span class="text-base-content/50">of ${format_cents(need.amount_cents)}</span>
                </div>
                <progress
                  class="progress progress-primary w-full"
                  value={need.funded_cents}
                  max={need.amount_cents}
                />
              </div>
              <div class="card-actions justify-end mt-3">
                <.link navigate={~p"/needs/#{need.id}"} class="btn btn-primary btn-sm shadow-sm shadow-primary/10">
                  View & Donate
                </.link>
              </div>
            </div>
          </div>
        </div>

        <div :if={@needs == []} class="text-center py-16 text-base-content/50">
          <.icon name="hero-inbox" class="size-12 text-base-content/20 mx-auto mb-4" />
          <p class="text-lg">No open needs at the moment. Check back soon!</p>
        </div>
      </div>
    </div>
    """
  end

  defp format_cents(cents) when is_integer(cents) do
    :erlang.float_to_binary(cents / 100, decimals: 2)
  end

  defp format_cents(_), do: "0.00"
end
