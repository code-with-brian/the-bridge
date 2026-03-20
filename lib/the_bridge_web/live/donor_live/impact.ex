defmodule TheBridgeWeb.DonorLive.Impact do
  use TheBridgeWeb, :live_view

  alias TheBridge.Impact

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    impact = Impact.donor_impact(user.id)

    {:ok,
     socket
     |> assign(:page_title, "My Impact")
     |> assign(:impact, impact)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-2xl font-bold">My Impact</h1>

      <div class="stats stats-vertical lg:stats-horizontal shadow w-full">
        <div class="stat">
          <div class="stat-title">Total Given</div>
          <div class="stat-value text-primary">${format_cents(@impact.total_donated_cents)}</div>
        </div>
        <div class="stat">
          <div class="stat-title">Donations</div>
          <div class="stat-value">{@impact.donation_count}</div>
        </div>
        <div class="stat">
          <div class="stat-title">Needs Supported</div>
          <div class="stat-value">{@impact.needs_supported}</div>
        </div>
        <div class="stat">
          <div class="stat-title">People Helped</div>
          <div class="stat-value text-success">{@impact.clients_helped}</div>
        </div>
      </div>
    </div>
    """
  end

  defp format_cents(cents) when is_integer(cents),
    do: :erlang.float_to_binary(cents / 100, decimals: 2)

  defp format_cents(_), do: "0.00"
end
