defmodule TheBridgeWeb.ClientLive.Show do
  use TheBridgeWeb, :live_view

  alias TheBridge.Clients

  @impl true
  def mount(%{"bridge_id" => bridge_id}, _session, socket) do
    client = Clients.get_client_by_bridge_id!(bridge_id)
    updates = Clients.list_public_updates_for_client(client.id)

    open_needs =
      client.needs
      |> Enum.filter(&(&1.status in ~w(open partially_funded)))

    {:ok,
     socket
     |> assign(:page_title, client.alias_name)
     |> assign(:client, client)
     |> assign(:open_needs, open_needs)
     |> assign(:updates, updates)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex items-center gap-4">
        <div class="avatar placeholder">
          <div class="bg-neutral text-neutral-content rounded-full w-16">
            <span class="text-xl">{@client.initials}</span>
          </div>
        </div>
        <div>
          <h1 class="text-2xl font-bold">{@client.alias_name}</h1>
          <p class="text-base-content/70">
            Bridge ID: {@client.bridge_id}
            <span :if={@client.age_range}> ·  {@client.age_range}</span>
            <span :if={@client.housing_status}> ·  {humanize(@client.housing_status)}</span>
          </p>
        </div>
      </div>

      <div :if={@client.story} class="prose">
        <h2 class="text-lg font-bold">Story</h2>
        <p>{@client.story}</p>
      </div>

      <section :if={@open_needs != []}>
        <h2 class="text-lg font-bold mb-4">Current Needs</h2>
        <div class="space-y-3">
          <div :for={need <- @open_needs} class="card bg-base-200">
            <div class="card-body py-4">
              <div class="flex justify-between items-start">
                <div>
                  <span class="badge badge-sm mr-2">{need.category}</span>
                  <span :if={need.priority == "urgent"} class="badge badge-error badge-sm">
                    Urgent
                  </span>
                  <h3 class="font-semibold mt-1">{need.title}</h3>
                  <p :if={need.description} class="text-sm text-base-content/70 mt-1">
                    {need.description}
                  </p>
                </div>
                <div class="text-right">
                  <div class="font-bold">
                    ${format_cents(need.amount_cents - need.funded_cents)} needed
                  </div>
                  <progress
                    class="progress progress-primary w-32 mt-1"
                    value={need.funded_cents}
                    max={need.amount_cents}
                  />
                  <div class="mt-2">
                    <.link navigate={~p"/needs/#{need.id}"} class="btn btn-primary btn-sm">
                      Donate
                    </.link>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section :if={@updates != []}>
        <h2 class="text-lg font-bold mb-4">Updates</h2>
        <div class="space-y-3">
          <div :for={update <- @updates} class="card bg-base-200">
            <div class="card-body py-3">
              <div class="flex justify-between items-center">
                <span class="badge badge-sm">{humanize(update.update_type)}</span>
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

  defp format_cents(cents) when is_integer(cents) do
    :erlang.float_to_binary(cents / 100, decimals: 2)
  end

  defp format_cents(_), do: "0.00"

  defp humanize(str), do: str |> String.replace("_", " ") |> String.capitalize()
end
