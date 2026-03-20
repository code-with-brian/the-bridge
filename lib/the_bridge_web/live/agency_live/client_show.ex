defmodule TheBridgeWeb.AgencyLive.ClientShow do
  use TheBridgeWeb, :live_view

  alias TheBridge.Clients

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    client = Clients.get_client!(id)
    needs = Clients.list_needs_for_client(client.id)
    updates = Clients.list_updates_for_client(client.id)

    {:ok,
     socket
     |> assign(:page_title, "#{client.first_name} #{client.last_name}")
     |> assign(:client, client)
     |> assign(:needs, needs)
     |> assign(:updates, updates)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex justify-between items-center">
        <div>
          <h1 class="text-2xl font-bold">{@client.first_name} {@client.last_name}</h1>
          <p class="text-base-content/70">
            Bridge ID: {@client.bridge_id} · Alias: {@client.alias_name}
          </p>
        </div>
        <div class="flex gap-2">
          <.link navigate={~p"/agency/clients/#{@client.id}/edit"} class="btn btn-outline btn-sm">
            Edit
          </.link>
          <.link navigate={~p"/agency/clients/#{@client.id}/needs/new"} class="btn btn-primary btn-sm">
            Add Need
          </.link>
          <.link
            navigate={~p"/agency/clients/#{@client.id}/updates/new"}
            class="btn btn-outline btn-sm"
          >
            Add Update
          </.link>
        </div>
      </div>

      <div class="grid grid-cols-2 gap-4">
        <div class="card bg-base-200 p-4">
          <h3 class="font-bold mb-2">Details</h3>
          <dl class="space-y-1 text-sm">
            <div class="flex justify-between">
              <dt class="text-base-content/70">Status</dt>
              <dd><span class="badge">{@client.status}</span></dd>
            </div>
            <div class="flex justify-between">
              <dt class="text-base-content/70">Housing</dt>
              <dd>{(@client.housing_status && humanize(@client.housing_status)) || "—"}</dd>
            </div>
            <div class="flex justify-between">
              <dt class="text-base-content/70">Gender</dt>
              <dd>{@client.gender || "—"}</dd>
            </div>
            <div class="flex justify-between">
              <dt class="text-base-content/70">DOB</dt>
              <dd>{@client.date_of_birth || "—"}</dd>
            </div>
            <div class="flex justify-between">
              <dt class="text-base-content/70">Consent</dt>
              <dd>{if @client.consent_signed, do: "Yes", else: "No"}</dd>
            </div>
          </dl>
        </div>

        <div :if={@client.notes} class="card bg-base-200 p-4">
          <h3 class="font-bold mb-2">Private Notes</h3>
          <p class="text-sm">{@client.notes}</p>
        </div>
      </div>

      <section>
        <h2 class="text-lg font-bold mb-3">Needs ({length(@needs)})</h2>
        <div class="space-y-2">
          <div :for={need <- @needs} class="card bg-base-200">
            <div class="card-body py-3 flex-row justify-between items-center">
              <div>
                <span class="badge badge-sm mr-2">{need.category}</span>
                <span class="font-semibold">{need.title}</span>
                <span class="badge badge-sm ml-2">{need.status}</span>
              </div>
              <div class="text-right">
                <span>${format_cents(need.funded_cents)} / ${format_cents(need.amount_cents)}</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section>
        <h2 class="text-lg font-bold mb-3">Updates ({length(@updates)})</h2>
        <div class="space-y-2">
          <div :for={update <- @updates} class="card bg-base-200">
            <div class="card-body py-3">
              <div class="flex justify-between items-center">
                <div>
                  <span class="badge badge-sm">{humanize(update.update_type)}</span>
                  <span :if={update.public} class="badge badge-sm badge-success ml-1">Public</span>
                </div>
                <span class="text-xs text-base-content/50">
                  {Calendar.strftime(update.inserted_at, "%b %d, %Y")}
                </span>
              </div>
              <p class="text-sm mt-1">{update.body}</p>
            </div>
          </div>
        </div>
      </section>
    </div>
    """
  end

  defp format_cents(cents) when is_integer(cents),
    do: :erlang.float_to_binary(cents / 100, decimals: 2)

  defp format_cents(_), do: "0.00"
  defp humanize(str), do: str |> String.replace("_", " ") |> String.capitalize()
end
