defmodule TheBridgeWeb.AdminLive.Moderation do
  use TheBridgeWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Moderation")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-2xl font-bold">Moderation</h1>
      <p class="text-base-content/70">Flagged content and moderation queue will appear here.</p>
    </div>
    """
  end
end
