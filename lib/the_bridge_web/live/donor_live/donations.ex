defmodule TheBridgeWeb.DonorLive.Donations do
  use TheBridgeWeb, :live_view

  alias TheBridge.Donations

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    donations = Donations.list_donations_for_donor(user.id)

    {:ok,
     socket
     |> assign(:page_title, "My Donations")
     |> assign(:donations, donations)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-2xl font-bold">My Donations</h1>

      <div class="space-y-3">
        <div :for={donation <- @donations} class="card bg-base-200">
          <div class="card-body py-4 flex-row justify-between items-center">
            <div>
              <h3 class="font-semibold">{donation.need.title}</h3>
              <p class="text-sm text-base-content/70">
                {Calendar.strftime(donation.inserted_at, "%b %d, %Y")}
              </p>
            </div>
            <div class="text-right">
              <span class="font-bold text-lg">${format_cents(donation.amount_cents)}</span>
              <p class="text-xs text-success">Completed</p>
            </div>
          </div>
        </div>
      </div>

      <div :if={@donations == []} class="text-center py-12 text-base-content/50">
        No donations yet. <.link navigate={~p"/needs"} class="link">Browse needs</.link>
        to make your first donation.
      </div>
    </div>
    """
  end

  defp format_cents(cents) when is_integer(cents),
    do: :erlang.float_to_binary(cents / 100, decimals: 2)

  defp format_cents(_), do: "0.00"
end
