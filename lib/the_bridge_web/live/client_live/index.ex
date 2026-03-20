defmodule TheBridgeWeb.ClientLive.Index do
  use TheBridgeWeb, :live_view

  alias TheBridge.Clients

  @impl true
  def mount(_params, _session, socket) do
    clients = Clients.list_clients()

    {:ok,
     socket
     |> assign(:page_title, "Browse Clients")
     |> assign(:clients, clients)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-2xl font-bold">People We Serve</h1>
      <p class="text-base-content/70">
        Each person below has been verified by a trusted social service agency.
      </p>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div :for={client <- @clients} class="card bg-base-200 shadow-sm">
          <div class="card-body">
            <h2 class="card-title">{client.alias_name}</h2>
            <div class="flex gap-2">
              <span :if={client.age_range} class="badge badge-outline">{client.age_range}</span>
              <span :if={client.housing_status} class="badge badge-outline">
                {humanize(client.housing_status)}
              </span>
            </div>
            <p :if={client.story} class="text-sm mt-2 line-clamp-3">{client.story}</p>
            <div class="card-actions justify-end mt-2">
              <.link navigate={~p"/clients/#{client.bridge_id}"} class="btn btn-primary btn-sm">
                View Profile
              </.link>
            </div>
          </div>
        </div>
      </div>

      <div :if={@clients == []} class="text-center py-12 text-base-content/50">
        No client profiles available yet.
      </div>
    </div>
    """
  end

  defp humanize(str) do
    str |> String.replace("_", " ") |> String.capitalize()
  end
end
