defmodule TheBridgeWeb.DonorLive.DonationShow do
  use TheBridgeWeb, :live_view

  alias TheBridge.Donations

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    donation = Donations.get_donation!(id)

    {:ok,
     socket
     |> assign(:page_title, "Donation Details")
     |> assign(:donation, donation)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-lg mx-auto space-y-6">
      <.link navigate={~p"/my-donations"} class="btn btn-ghost btn-sm">&larr; Back</.link>

      <h1 class="text-2xl font-bold">Donation Details</h1>

      <div class="card bg-base-200">
        <div class="card-body">
          <dl class="space-y-3">
            <div class="flex justify-between">
              <dt class="text-base-content/70">Amount</dt>
              <dd class="font-bold">${format_cents(@donation.amount_cents)}</dd>
            </div>
            <div class="flex justify-between">
              <dt class="text-base-content/70">Status</dt>
              <dd><span class="badge badge-success">{@donation.status}</span></dd>
            </div>
            <div class="flex justify-between">
              <dt class="text-base-content/70">Need</dt>
              <dd>
                <.link navigate={~p"/needs/#{@donation.need_id}"} class="link">
                  {@donation.need.title}
                </.link>
              </dd>
            </div>
            <div class="flex justify-between">
              <dt class="text-base-content/70">Date</dt>
              <dd>{Calendar.strftime(@donation.inserted_at, "%b %d, %Y at %I:%M %p")}</dd>
            </div>
            <div :if={@donation.message} class="flex justify-between">
              <dt class="text-base-content/70">Message</dt>
              <dd>{@donation.message}</dd>
            </div>
            <div class="flex justify-between">
              <dt class="text-base-content/70">Anonymous</dt>
              <dd>{if @donation.anonymous, do: "Yes", else: "No"}</dd>
            </div>
          </dl>
        </div>
      </div>
    </div>
    """
  end

  defp format_cents(cents) when is_integer(cents),
    do: :erlang.float_to_binary(cents / 100, decimals: 2)

  defp format_cents(_), do: "0.00"
end
