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
      <.link navigate={~p"/needs"} class="btn btn-ghost btn-sm">
        &larr; Back to Needs
      </.link>

      <div class="card bg-base-200">
        <div class="card-body">
          <div class="flex gap-2 mb-2">
            <span class="badge">{@need.category}</span>
            <span :if={@need.priority == "urgent"} class="badge badge-error">Urgent</span>
            <span :if={@need.priority == "high"} class="badge badge-warning">High</span>
          </div>
          <h1 class="card-title text-2xl">{@need.title}</h1>
          <p :if={@need.description} class="mt-2">{@need.description}</p>

          <div class="mt-4">
            <div class="flex justify-between text-sm mb-1">
              <span>${format_cents(@need.funded_cents)} raised</span>
              <span>${format_cents(@need.amount_cents)} goal</span>
            </div>
            <progress
              class="progress progress-primary w-full"
              value={@need.funded_cents}
              max={@need.amount_cents}
            />
            <p class="text-sm text-base-content/50 mt-1">
              {funding_percentage(@need)}% funded
            </p>
          </div>

          <div :if={@need.status in ~w(open partially_funded)} class="card-actions justify-end mt-4">
            <.link navigate={~p"/needs/#{@need.id}/donate"} class="btn btn-primary">
              Donate Now
            </.link>
          </div>

          <div :if={@need.status == "funded"} class="alert alert-success mt-4">
            This need has been fully funded! Thank you to all donors.
          </div>

          <div :if={@need.status == "fulfilled"} class="alert alert-success mt-4">
            This need has been fulfilled!
          </div>
        </div>
      </div>

      <div class="mt-4">
        <.link navigate={~p"/clients/#{@need.client.bridge_id}"} class="link">
          View {@need.client.alias_name}'s profile
        </.link>
      </div>

      <section :if={@donations != []}>
        <h2 class="text-lg font-bold mb-4">Donations ({length(@donations)})</h2>
        <div class="space-y-2">
          <div
            :for={donation <- @donations}
            class="flex justify-between items-center py-2 border-b border-base-300"
          >
            <div>
              <span :if={donation.anonymous}>Anonymous</span>
              <span :if={!donation.anonymous && donation.donor_id}>A donor</span>
              <span :if={donation.message} class="text-sm text-base-content/70 ml-2">
                "{donation.message}"
              </span>
            </div>
            <span class="font-semibold">${format_cents(donation.amount_cents)}</span>
          </div>
        </div>
      </section>
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
