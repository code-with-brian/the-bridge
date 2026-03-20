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
    <div class="space-y-6">
      <div class="flex justify-between items-center">
        <h1 class="text-2xl font-bold">Open Needs</h1>
      </div>

      <div class="flex gap-2 flex-wrap">
        <button
          phx-click="filter"
          phx-value-category=""
          class={["btn btn-sm", (!@category_filter && "btn-primary") || "btn-outline"]}
        >
          All
        </button>
        <button
          :for={cat <- Need.categories()}
          phx-click="filter"
          phx-value-category={cat}
          class={["btn btn-sm", (@category_filter == cat && "btn-primary") || "btn-outline"]}
        >
          {String.capitalize(cat)}
        </button>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div :for={need <- @needs} class="card bg-base-200 shadow-sm">
          <div class="card-body">
            <div class="flex gap-2">
              <span class="badge">{need.category}</span>
              <span :if={need.priority == "urgent"} class="badge badge-error">Urgent</span>
              <span :if={need.priority == "high"} class="badge badge-warning">High</span>
            </div>
            <h3 class="card-title text-base">{need.title}</h3>
            <p class="text-sm text-base-content/70">{need.client.alias_name}</p>
            <div class="flex justify-between items-center mt-2">
              <div>
                <span class="font-bold">${format_cents(need.funded_cents)}</span>
                <span class="text-base-content/50"> of ${format_cents(need.amount_cents)}</span>
              </div>
              <progress
                class="progress progress-primary w-24"
                value={need.funded_cents}
                max={need.amount_cents}
              />
            </div>
            <div class="card-actions justify-end mt-2">
              <.link navigate={~p"/needs/#{need.id}"} class="btn btn-primary btn-sm">
                View & Donate
              </.link>
            </div>
          </div>
        </div>
      </div>

      <div :if={@needs == []} class="text-center py-12 text-base-content/50">
        No open needs at the moment. Check back soon!
      </div>
    </div>
    """
  end

  defp format_cents(cents) when is_integer(cents) do
    :erlang.float_to_binary(cents / 100, decimals: 2)
  end

  defp format_cents(_), do: "0.00"
end
