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
      <section class="relative -mx-4 sm:-mx-6 lg:-mx-8 px-4 sm:px-6 lg:px-8 bg-gradient-to-br from-primary/5 via-base-100 to-accent/30">
        <div class="max-w-6xl mx-auto grid lg:grid-cols-2 gap-12 items-center py-20 lg:py-28">
          <%!-- Left column — text --%>
          <div>
            <div class="inline-flex items-center gap-2 badge bg-primary/10 text-primary border-primary/20 px-4 py-2 mb-6">
              <.icon name="hero-map-pin" class="size-3.5" />
              Now Live in Peterborough, ON
            </div>
            <h1 class="text-4xl md:text-5xl lg:text-6xl font-bold leading-[1.1] mb-6">
              Community-powered
              <span class="relative inline-block text-primary">
                pathways forward
                <svg class="absolute -bottom-2 left-0 w-full" viewBox="0 0 200 12" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M2 8.5C30 3 70 2 100 4C130 6 170 3 198 7" stroke="currentColor" stroke-width="3" stroke-linecap="round" opacity="0.4" />
                </svg>
              </span>
            </h1>
            <p class="text-lg text-base-content/60 leading-relaxed max-w-lg mb-8">
              Connect directly with neighbours experiencing homelessness through transparent,
              agency-verified support pathways. 100% of donations go to the goal.
            </p>
            <div class="flex flex-col sm:flex-row gap-4 mb-8">
              <.link navigate={~p"/needs"} class="btn btn-primary btn-lg shadow-xl shadow-primary/20 hover:shadow-primary/40 hover:-translate-y-0.5 transition-all duration-300">
                <.icon name="hero-heart" class="size-5" /> Browse Needs
              </.link>
              <.link navigate={~p"/impact"} class="btn btn-outline border-primary/20 hover:bg-primary/5 btn-lg">
                How it Works
              </.link>
            </div>
            <%!-- Social proof --%>
            <div class="flex items-center gap-3">
              <div class="flex -space-x-3">
                <img src={~p"/images/headshot-0.jpg"} class="w-10 h-10 rounded-full border-2 border-base-100 object-cover" alt="" />
                <img src={~p"/images/headshot-1.jpg"} class="w-10 h-10 rounded-full border-2 border-base-100 object-cover" alt="" />
                <img src={~p"/images/headshot-2.jpg"} class="w-10 h-10 rounded-full border-2 border-base-100 object-cover" alt="" />
                <img src={~p"/images/headshot-3.jpg"} class="w-10 h-10 rounded-full border-2 border-base-100 object-cover" alt="" />
              </div>
              <p class="text-sm text-base-content/60">
                Joined by <span class="font-bold text-base-content">400+</span> local supporters
              </p>
            </div>
          </div>

          <%!-- Right column — hero image --%>
          <div class="relative rounded-2xl overflow-hidden shadow-2xl">
            <img
              src={~p"/images/Community_support_in_park_ff7ec8ed.png"}
              alt="Community members supporting each other in a park"
              class="w-full h-full object-cover aspect-[4/3]"
            />
            <div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent" />
            <%!-- Testimonial overlay --%>
            <div class="absolute bottom-0 left-0 right-0 p-6">
              <blockquote class="text-white/90 text-sm leading-relaxed mb-2">
                "The Bridge helped me get back on my feet. Knowing real people in my community
                cared enough to help — that changed everything."
              </blockquote>
              <div class="flex items-center gap-2">
                <span class="text-white/70 text-xs">— Bridge participant</span>
                <span class="inline-flex items-center gap-1 bg-secondary/90 text-secondary-content text-xs px-2 py-0.5 rounded-full">
                  <.icon name="hero-check-badge-solid" class="size-3" /> Agency Verified
                </span>
              </div>
            </div>
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

      <%!-- Why The Bridge is Different --%>
      <section class="bg-base-200/30 border-y border-base-300/50 -mx-4 sm:-mx-6 lg:-mx-8 px-4 sm:px-6 lg:px-8 py-16">
        <div class="max-w-5xl mx-auto text-center">
          <h2 class="text-3xl md:text-4xl font-bold mb-4">Why The Bridge is Different</h2>
          <p class="text-base-content/60 max-w-2xl mx-auto mb-10">
            Traditional crowdfunding isn't built for complex social challenges. We bridge the gap
            with verification, transparency, and professional support.
          </p>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div class="bg-base-100 p-8 rounded-xl border border-base-300/50 shadow-sm hover:shadow-md transition-shadow text-center">
              <div class="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mx-auto mb-4">
                <.icon name="hero-shield-check" class="size-6 text-primary" />
              </div>
              <h3 class="font-bold text-lg mb-2">Verified & Secure</h3>
              <p class="text-base-content/60 text-sm leading-relaxed">
                Every need is created and managed by established local social service agencies.
                No fraud, just impact.
              </p>
            </div>
            <div class="bg-base-100 p-8 rounded-xl border border-base-300/50 shadow-sm hover:shadow-md transition-shadow text-center">
              <div class="w-12 h-12 bg-secondary/10 rounded-lg flex items-center justify-center mx-auto mb-4">
                <.icon name="hero-chart-bar" class="size-6 text-secondary" />
              </div>
              <h3 class="font-bold text-lg mb-2">Transparent Tracking</h3>
              <p class="text-base-content/60 text-sm leading-relaxed">
                See exactly where funds go. Budgets are clear, and every donation is tracked
                from pledge to fulfillment.
              </p>
            </div>
            <div class="bg-base-100 p-8 rounded-xl border border-base-300/50 shadow-sm hover:shadow-md transition-shadow text-center">
              <div class="w-12 h-12 bg-success/10 rounded-lg flex items-center justify-center mx-auto mb-4">
                <.icon name="hero-heart" class="size-6 text-success" />
              </div>
              <h3 class="font-bold text-lg mb-2">Holistic Support</h3>
              <p class="text-base-content/60 text-sm leading-relaxed">
                It's more than money. Participants receive ongoing casework support to ensure
                long-term success.
              </p>
            </div>
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
            <div :for={need <- @featured_needs} class="card bg-base-100 border border-base-300/60 hover:border-primary/30 hover:shadow-lg transition-all duration-300 hover:-translate-y-1 overflow-hidden">
              <div class="relative h-48 overflow-hidden">
                <img
                  src={need_image(need.category)}
                  alt=""
                  class="w-full h-full object-cover"
                />
                <div class="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent" />
                <span class="absolute top-3 left-3 badge bg-base-100/90 backdrop-blur-sm border-0 text-xs">
                  {need.category || "General"}
                </span>
                <span :if={need.priority == "urgent"} class="absolute top-3 right-3 badge badge-error text-xs">
                  Urgent
                </span>
              </div>
              <div class="card-body">
                <h3 class="card-title text-base">{need.title}</h3>
                <p class="text-sm text-base-content/60 flex items-center gap-1">
                  <.icon name="hero-check-badge-solid" class="size-4 text-success" />
                  Verified — {need.client.alias_name}
                </p>
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
          <h2 class="text-3xl md:text-5xl font-bold mb-4">Ready to make a real difference?</h2>
          <p class="text-primary-content/80 text-lg mb-8 leading-relaxed">
            Join hundreds of locals building a stronger, more connected community.
            Your support can change a life today.
          </p>
          <div class="flex flex-col sm:flex-row gap-4 justify-center">
            <.link navigate={~p"/needs"} class="btn btn-lg bg-secondary text-secondary-content hover:bg-secondary/90 border-0 shadow-lg">
              <.icon name="hero-heart" class="size-5" /> Find a Need
            </.link>
            <.link navigate={~p"/users/register"} class="btn btn-lg btn-outline border-primary-content/30 text-primary-content hover:bg-primary-content/10 hover:border-primary-content/50">
              Partner as an Agency
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
end
