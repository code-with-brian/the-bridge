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

      <%!-- Hero image banner --%>
      <div class="relative h-64 md:h-80 rounded-2xl overflow-hidden shadow-lg">
        <img
          src={need_image(@need.category)}
          alt=""
          class="w-full h-full object-cover"
        />
        <div class="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent" />
        <%!-- Status badge top-right --%>
        <div class="absolute top-4 right-4 flex gap-2">
          <span :if={@need.status == "funded"} class="badge bg-success text-success-content border-0">Fully Funded</span>
          <span :if={@need.status == "fulfilled"} class="badge bg-success text-success-content border-0">Fulfilled</span>
          <span :if={@need.priority == "urgent"} class="badge badge-error">Urgent</span>
          <span :if={@need.priority == "high"} class="badge badge-warning">High Priority</span>
        </div>
        <%!-- Title overlay bottom-left --%>
        <div class="absolute bottom-0 left-0 right-0 p-6 md:p-8">
          <div class="flex gap-2 mb-3">
            <span class="badge bg-base-100/90 backdrop-blur-sm border-0 text-xs">{@need.category || "General"}</span>
          </div>
          <h1 class="text-2xl md:text-4xl font-bold text-white mb-1">{@need.title}</h1>
          <p class="text-white/70 text-sm flex items-center gap-1.5">
            <.icon name="hero-check-badge-solid" class="size-4 text-secondary" />
            Verified —
            <.link navigate={~p"/clients/#{@need.client.bridge_id}"} class="text-white hover:text-white/90 underline underline-offset-2">{@need.client.alias_name}</.link>
          </p>
        </div>
      </div>

      <div class="grid lg:grid-cols-3 gap-8">
        <%!-- Left column: details --%>
        <div class="lg:col-span-2 space-y-6">
          <%!-- About This Need --%>
          <div class="bg-base-100 rounded-xl border border-base-300/50 p-6 md:p-8">
            <h2 class="text-lg font-bold mb-4">About This Need</h2>
            <p :if={@need.description} class="text-base-content/70 leading-relaxed whitespace-pre-line">{@need.description}</p>
            <p :if={!@need.description} class="text-base-content/40 italic">No description provided.</p>

            <%!-- Caseworker Notes --%>
            <div :if={@need.vendor_notes} class="mt-6 bg-info/5 border border-info/20 rounded-lg p-4">
              <h3 class="text-sm font-semibold text-info flex items-center gap-1.5 mb-2">
                <.icon name="hero-clipboard-document-list" class="size-4" />
                Caseworker Notes
              </h3>
              <p class="text-sm text-base-content/70 leading-relaxed">{@need.vendor_notes}</p>
            </div>
          </div>

          <%!-- Donations --%>
          <section :if={@donations != []} class="bg-base-100 rounded-xl border border-base-300/50 p-6 md:p-8">
            <h2 class="text-lg font-bold mb-4">Donations ({length(@donations)})</h2>
            <div class="space-y-0">
              <div
                :for={{donation, idx} <- Enum.with_index(@donations)}
                class="flex items-center gap-3 py-3 border-b border-base-300/50 last:border-0"
              >
                <img
                  src={headshot_image(idx)}
                  class="w-9 h-9 rounded-full object-cover shrink-0"
                  alt=""
                />
                <div class="flex-1 min-w-0">
                  <span :if={donation.anonymous} class="font-medium">Anonymous</span>
                  <span :if={!donation.anonymous && donation.donor_id} class="font-medium">A supporter</span>
                  <p :if={donation.message} class="text-sm text-base-content/60 truncate">
                    "{donation.message}"
                  </p>
                </div>
                <span class="font-semibold shrink-0">${format_cents(donation.amount_cents)}</span>
              </div>
            </div>
          </section>
        </div>

        <%!-- Right column: sticky sidebar --%>
        <div class="lg:col-span-1">
          <div class="sticky top-24 space-y-4">
            <%!-- Funding card --%>
            <div class="bg-base-100 rounded-xl border border-base-300/50 p-6 shadow-sm">
              <div class="mb-4">
                <div class="flex items-baseline justify-between mb-1">
                  <span class="text-2xl font-bold">${format_cents(@need.funded_cents)}</span>
                  <span class="text-sm text-base-content/50">of ${format_cents(@need.amount_cents)}</span>
                </div>
                <progress
                  class="progress progress-primary w-full"
                  value={@need.funded_cents}
                  max={@need.amount_cents}
                />
                <div class="mt-2">
                  <span class="badge badge-sm bg-primary/10 text-primary border-0">
                    {funding_percentage(@need)}% funded
                  </span>
                </div>
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

            <%!-- Trust & Safety --%>
            <div class="bg-success/5 rounded-xl border border-success/20 p-5">
              <h3 class="text-sm font-semibold mb-3 text-base-content/70">Trust & Safety</h3>
              <ul class="space-y-2.5 text-sm text-base-content/60">
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
                <li class="flex items-center gap-2">
                  <.icon name="hero-heart" class="size-4 text-success shrink-0" />
                  100% of donations go to the goal
                </li>
              </ul>
            </div>

            <%!-- Share --%>
            <div class="bg-base-100 rounded-xl border border-base-300/50 p-5">
              <h3 class="text-sm font-semibold mb-3 text-base-content/70">Share This Need</h3>
              <button
                onclick="navigator.clipboard.writeText(window.location.href).then(() => { this.querySelector('span').textContent = 'Copied!'; setTimeout(() => this.querySelector('span').textContent = 'Copy Link', 2000) })"
                class="btn btn-outline btn-sm w-full gap-2"
              >
                <.icon name="hero-link" class="size-4" />
                <span>Copy Link</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp headshot_image(idx) do
    case rem(idx, 15) do
      0 -> ~p"/images/headshot-0.jpg"
      1 -> ~p"/images/headshot-1.jpg"
      2 -> ~p"/images/headshot-2.jpg"
      3 -> ~p"/images/headshot-3.jpg"
      4 -> ~p"/images/headshot-4.jpg"
      5 -> ~p"/images/headshot-5.jpg"
      6 -> ~p"/images/headshot-6.jpg"
      7 -> ~p"/images/headshot-7.jpg"
      8 -> ~p"/images/headshot-8.jpg"
      9 -> ~p"/images/headshot-9.jpg"
      10 -> ~p"/images/headshot-10.jpg"
      11 -> ~p"/images/headshot-11.jpg"
      12 -> ~p"/images/headshot-12.jpg"
      13 -> ~p"/images/headshot-13.jpg"
      14 -> ~p"/images/headshot-14.jpg"
    end
  end

  defp need_image(category) do
    case category do
      "housing" -> ~p"/images/Empty_sunny_apartment_49030cce.png"
      cat when cat in ~w(medical health) -> ~p"/images/Medical_glasses_and_papers_7afb4b5c.png"
      cat when cat in ~w(education employment) -> ~p"/images/Study_materials_on_table_a3761546.png"
      _ -> ~p"/images/Community_support_in_park_ff7ec8ed.png"
    end
  end

  defp format_cents(cents) when is_integer(cents) do
    :erlang.float_to_binary(cents / 100, decimals: 2)
  end

  defp format_cents(_), do: "0.00"

  defp funding_percentage(need) do
    TheBridge.Clients.Need.funding_percentage(need)
  end
end
