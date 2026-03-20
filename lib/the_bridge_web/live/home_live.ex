defmodule TheBridgeWeb.HomeLive do
  use TheBridgeWeb, :live_view

  alias TheBridge.{Impact, Agencies}

  @impl true
  def mount(_params, _session, socket) do
    stats = Impact.platform_stats()
    featured_needs = list_featured_needs()
    verified_agencies = Agencies.list_verified_agencies()

    {:ok,
     socket
     |> assign(:page_title, "The Bridge — Connecting Generosity with Verified Needs")
     |> assign(:stats, stats)
     |> assign(:featured_needs, featured_needs)
     |> assign(:verified_agencies, verified_agencies)}
  end

  defp list_featured_needs do
    import Ecto.Query

    TheBridge.Clients.Need
    |> where([n], n.status in ~w(open partially_funded))
    |> order_by([n], [desc: n.priority == "urgent", desc: n.inserted_at])
    |> limit(6)
    |> preload(:client)
    |> TheBridge.Repo.all()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-16">
      <%!-- Hero Section --%>
      <section class="relative bg-gradient-to-br from-primary/5 via-base-100 to-accent/30 -mx-4 sm:-mx-6 lg:-mx-8 px-4 sm:px-6 lg:px-8">
        <div class="text-center py-24 lg:py-32 max-w-3xl mx-auto">
          <div class="inline-flex items-center gap-2 badge bg-primary/10 text-primary border-primary/20 px-4 py-2 mb-6">
            <.icon name="hero-map-pin" class="size-3.5" />
            Now Live in Peterborough, ON
          </div>
          <h1 class="text-5xl md:text-6xl lg:text-7xl font-bold leading-[1.1] mb-6">
            Connecting Generosity with <span class="text-primary">Verified Need</span>
          </h1>
          <p class="text-xl text-base-content/60 leading-relaxed max-w-2xl mx-auto mb-10">
            A transparent platform where community members fund specific, verified needs
            for individuals experiencing homelessness.
          </p>
          <div class="flex flex-col sm:flex-row gap-4 justify-center">
            <.link navigate={~p"/needs"} class="btn btn-primary btn-lg shadow-xl shadow-primary/20 hover:shadow-primary/40 hover:-translate-y-0.5 transition-all duration-300">
              <.icon name="hero-heart" class="size-5" /> Browse Needs
            </.link>
            <.link navigate={~p"/impact"} class="btn btn-outline border-primary/20 hover:bg-primary/5 btn-lg">
              <.icon name="hero-chart-bar" class="size-5" /> See Our Impact
            </.link>
          </div>
        </div>
      </section>

      <%!-- Stats Section --%>
      <section>
        <%= if stats_empty?(@stats) do %>
          <div class="text-center py-8">
            <div class="inline-flex items-center gap-2 text-primary mb-3">
              <.icon name="hero-sparkles" class="size-6" />
              <span class="text-lg font-semibold">We're just getting started</span>
              <.icon name="hero-sparkles" class="size-6" />
            </div>
            <p class="text-base-content/70 max-w-lg mx-auto mb-6">
              The Bridge is building a community of donors and agencies working together.
              Be among the first to make a difference.
            </p>
            <.link navigate={~p"/needs"} class="btn btn-primary">
              Make the First Donation
            </.link>
          </div>
        <% else %>
          <div class="stats stats-vertical lg:stats-horizontal shadow w-full">
            <div class="stat">
              <div class="stat-figure text-primary">
                <.icon name="hero-heart" class="size-8" />
              </div>
              <div class="stat-title">Total Donated</div>
              <div class="stat-value text-primary">${format_cents(@stats.total_donated_cents)}</div>
            </div>
            <div class="stat">
              <div class="stat-figure text-secondary">
                <.icon name="hero-users" class="size-8" />
              </div>
              <div class="stat-title">Donors</div>
              <div class="stat-value">{@stats.total_donors}</div>
            </div>
            <div class="stat">
              <div class="stat-figure text-accent">
                <.icon name="hero-home" class="size-8" />
              </div>
              <div class="stat-title">People Served</div>
              <div class="stat-value">{@stats.total_clients_served}</div>
            </div>
            <div class="stat">
              <div class="stat-figure text-success">
                <.icon name="hero-check-circle" class="size-8" />
              </div>
              <div class="stat-title">Needs Fulfilled</div>
              <div class="stat-value text-success">{@stats.total_needs_fulfilled}</div>
            </div>
          </div>
        <% end %>
      </section>

      <%!-- How It Works --%>
      <section class="text-center py-8">
        <h2 class="text-3xl md:text-4xl font-bold mb-10">How It Works</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 max-w-5xl mx-auto">
          <div class="bg-base-100 p-8 rounded-xl border border-base-300/50 shadow-sm hover:shadow-md transition-shadow text-center">
            <div class="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mx-auto mb-4">
              <.icon name="hero-building-office-2" class="size-6 text-primary" />
            </div>
            <h3 class="font-bold text-lg mb-2">Agencies Create Profiles</h3>
            <p class="text-base-content/60 text-sm leading-relaxed">
              Verified social service agencies create profiles for clients with specific needs.
            </p>
          </div>
          <div class="bg-base-100 p-8 rounded-xl border border-base-300/50 shadow-sm hover:shadow-md transition-shadow text-center">
            <div class="w-12 h-12 bg-secondary/10 rounded-lg flex items-center justify-center mx-auto mb-4">
              <.icon name="hero-heart" class="size-6 text-secondary" />
            </div>
            <h3 class="font-bold text-lg mb-2">Donors Fund Needs</h3>
            <p class="text-base-content/60 text-sm leading-relaxed">
              Community members browse verified needs and donate directly to specific items.
            </p>
          </div>
          <div class="bg-base-100 p-8 rounded-xl border border-base-300/50 shadow-sm hover:shadow-md transition-shadow text-center">
            <div class="w-12 h-12 bg-success/10 rounded-lg flex items-center justify-center mx-auto mb-4">
              <.icon name="hero-check-badge" class="size-6 text-success" />
            </div>
            <h3 class="font-bold text-lg mb-2">Workers Fulfill</h3>
            <p class="text-base-content/60 text-sm leading-relaxed">
              Agency workers purchase items and provide updates on impact.
            </p>
          </div>
        </div>
      </section>

      <%!-- Featured Needs --%>
      <section>
        <%= if @featured_needs != [] do %>
          <div class="flex justify-between items-center mb-8">
            <h2 class="text-3xl md:text-4xl font-bold">Featured Needs</h2>
            <.link navigate={~p"/needs"} class="text-sm font-medium text-primary hover:text-primary/80 transition-colors flex items-center gap-1">
              View All <.icon name="hero-arrow-right" class="size-4" />
            </.link>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <div :for={need <- @featured_needs} class="card bg-base-100 border border-base-300/60 hover:border-primary/30 hover:shadow-lg transition-all duration-300 hover:-translate-y-1">
              <div class="card-body">
                <div class="flex gap-2">
                  <span class="badge bg-primary/10 text-primary border-0 text-xs">{need.category || "General"}</span>
                  <span :if={need.priority == "urgent"} class="badge badge-error text-xs">Urgent</span>
                </div>
                <h3 class="card-title text-base">{need.title}</h3>
                <p class="text-sm text-base-content/60">{need.client.alias_name}</p>
                <div class="mt-3">
                  <div class="flex justify-between text-sm mb-1.5">
                    <span class="font-semibold">${format_cents(need.funded_cents)} raised</span>
                    <span class="text-base-content/50">${format_cents(need.amount_cents)} goal</span>
                  </div>
                  <progress
                    class="progress progress-primary w-full"
                    value={need.funded_cents}
                    max={need.amount_cents}
                  />
                </div>
                <div class="card-actions justify-end mt-3">
                  <.link navigate={~p"/needs/#{need.id}"} class="btn btn-primary btn-sm shadow-sm shadow-primary/10">
                    Donate
                  </.link>
                </div>
              </div>
            </div>
          </div>
        <% else %>
          <div class="text-center py-12 bg-base-100 rounded-xl border border-base-300/50">
            <.icon name="hero-inbox" class="size-12 text-base-content/20 mx-auto mb-4" />
            <h2 class="text-2xl font-bold mb-2">No Open Needs Right Now</h2>
            <p class="text-base-content/60 max-w-md mx-auto mb-6">
              Our agencies are always identifying new needs. Check back soon or register
              your agency to start posting needs.
            </p>
            <.link navigate={~p"/users/register"} class="btn btn-primary shadow-lg shadow-primary/20">
              Register Your Agency
            </.link>
          </div>
        <% end %>
      </section>

      <%!-- Trusted Agencies --%>
      <section :if={@verified_agencies != []} class="text-center py-8">
        <h2 class="text-3xl md:text-4xl font-bold mb-2">Trusted Partner Agencies</h2>
        <p class="text-base-content/60 mb-8">
          Verified organizations working together to serve our community.
        </p>
        <div class="flex flex-wrap justify-center gap-4">
          <div
            :for={agency <- @verified_agencies}
            class="bg-base-100 border border-base-300/50 shadow-sm rounded-xl px-6 py-4 inline-flex flex-row items-center gap-3 hover:shadow-md transition-shadow"
          >
            <.icon name="hero-check-badge-solid" class="size-5 text-success shrink-0" />
            <span class="font-semibold">{agency.name}</span>
          </div>
        </div>
      </section>

      <%!-- CTA Section --%>
      <section class="bg-primary text-primary-content -mx-4 sm:-mx-6 lg:-mx-8 px-4 sm:px-6 lg:px-8 py-20 text-center">
        <div class="max-w-2xl mx-auto">
          <h2 class="text-3xl md:text-4xl font-bold mb-4">Ready to Make a Difference?</h2>
          <p class="text-primary-content/80 text-lg mb-8 leading-relaxed">
            Every donation goes directly to a verified need. Join our community of
            donors making a real impact in Peterborough.
          </p>
          <div class="flex flex-col sm:flex-row gap-4 justify-center">
            <.link navigate={~p"/needs"} class="btn btn-lg bg-white text-primary hover:bg-white/90 border-0">
              <.icon name="hero-heart" class="size-5" /> Browse Needs
            </.link>
            <.link navigate={~p"/users/register"} class="btn btn-lg btn-outline border-primary-content/30 text-primary-content hover:bg-primary-content/10 hover:border-primary-content/50">
              Create an Account
            </.link>
          </div>
        </div>
      </section>
    </div>
    """
  end

  defp stats_empty?(stats) do
    stats.total_donated_cents == 0 and stats.total_donors == 0 and
      stats.total_clients_served == 0 and stats.total_needs_fulfilled == 0
  end

  defp format_cents(cents) when is_integer(cents) do
    :erlang.float_to_binary(cents / 100, decimals: 2)
  end

  defp format_cents(_), do: "0.00"
end
