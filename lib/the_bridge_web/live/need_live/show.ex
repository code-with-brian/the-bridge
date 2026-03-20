defmodule TheBridgeWeb.NeedLive.Show do
  use TheBridgeWeb, :live_view

  alias TheBridge.Clients
  alias TheBridge.Donations

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    need = Clients.get_need!(id)
    donations = Donations.list_donations_for_need(id)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(TheBridge.PubSub, "need:#{id}")
    end

    {:ok,
     socket
     |> assign(:page_title, need.title)
     |> assign(:need, need)
     |> assign(:donations, donations)}
  end

  @impl true
  def handle_info({:need_updated, need}, socket) do
    {:noreply, assign(socket, :need, need)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.link navigate={~p"/needs"} class="text-sm text-base-content/50 hover:text-primary transition-colors inline-flex items-center gap-1">
        <.icon name="hero-arrow-left" class="size-3.5" /> Back to Needs
      </.link>

      <div class="grid lg:grid-cols-3 gap-8">
        <%!-- Left column: details --%>
        <div class="lg:col-span-2 space-y-6">
          <div class="bg-base-100 rounded-xl border border-base-300/50 p-6 md:p-8">
            <div class="flex gap-2 mb-3">
              <span class="badge bg-primary/10 text-primary border-0 text-xs">{@need.category}</span>
              <span :if={@need.priority == "urgent"} class="badge badge-error text-xs">Urgent</span>
              <span :if={@need.priority == "high"} class="badge badge-warning text-xs">High</span>
            </div>
            <h1 class="text-2xl md:text-3xl font-bold mb-2">{@need.title}</h1>
            <p class="text-sm text-base-content/50 mb-4">
              For <.link navigate={~p"/clients/#{@need.client.bridge_id}"} class="text-primary hover:underline">{@need.client.alias_name}</.link>
            </p>
            <p :if={@need.description} class="text-base-content/70 leading-relaxed">{@need.description}</p>
          </div>

          <section :if={@donations != []} class="bg-base-100 rounded-xl border border-base-300/50 p-6 md:p-8">
            <h2 class="text-lg font-bold mb-4">Donations ({length(@donations)})</h2>
            <div class="space-y-0">
              <div
                :for={donation <- @donations}
                class="flex justify-between items-center py-3 border-b border-base-300/50 last:border-0"
              >
                <div>
                  <span :if={donation.anonymous} class="font-medium">Anonymous</span>
                  <span :if={!donation.anonymous && donation.donor_id} class="font-medium">A donor</span>
                  <span :if={donation.message} class="text-sm text-base-content/60 ml-2">
                    "{donation.message}"
                  </span>
                </div>
                <span class="font-semibold">${format_cents(donation.amount_cents)}</span>
              </div>
            </div>
          </section>
        </div>

        <%!-- Right column: sticky sidebar --%>
        <div class="lg:col-span-1">
          <div class="sticky top-24 space-y-4">
            <div class="bg-base-100 rounded-xl border border-base-300/50 p-6 shadow-sm">
              <div class="mb-4">
                <div class="flex justify-between text-sm mb-1.5">
                  <span class="font-semibold">${format_cents(@need.funded_cents)} raised</span>
                  <span class="text-base-content/50">${format_cents(@need.amount_cents)} goal</span>
                </div>
                <progress
                  class="progress progress-primary w-full"
                  value={@need.funded_cents}
                  max={@need.amount_cents}
                />
                <p class="text-sm text-base-content/50 mt-1.5">
                  {funding_percentage(@need)}% funded
                </p>
              </div>

              <div :if={@need.status in ~w(open partially_funded)}>
                <.link navigate={~p"/needs/#{@need.id}/donate"} class="btn btn-primary w-full shadow-lg shadow-primary/20 hover:shadow-primary/40 hover:-translate-y-0.5 transition-all duration-300">
                  Donate Now
                </.link>
              </div>

              <div :if={@need.status == "funded"} class="alert alert-success">
                This need has been fully funded!
              </div>

              <div :if={@need.status == "fulfilled"} class="alert alert-success">
                This need has been fulfilled!
              </div>
            </div>

            <div class="bg-base-100 rounded-xl border border-base-300/50 p-5">
              <h3 class="text-sm font-semibold mb-3 text-base-content/70">Trust & Safety</h3>
              <ul class="space-y-2 text-sm text-base-content/60">
                <li class="flex items-center gap-2">
                  <.icon name="hero-check-badge" class="size-4 text-success shrink-0" />
                  Verified by partner agency
                </li>
                <li class="flex items-center gap-2">
                  <.icon name="hero-shield-check" class="size-4 text-success shrink-0" />
                  Funds tracked transparently
                </li>
                <li class="flex items-center gap-2">
                  <.icon name="hero-eye" class="size-4 text-success shrink-0" />
                  Fulfillment updates provided
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp format_cents(cents) when is_integer(cents) do
    :erlang.float_to_binary(cents / 100, decimals: 2)
  end

  defp format_cents(_), do: "0.00"

  defp funding_percentage(need) do
    TheBridge.Clients.Need.funding_percentage(need)
  end
end
