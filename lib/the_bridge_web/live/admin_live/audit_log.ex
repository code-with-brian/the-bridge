defmodule TheBridgeWeb.AdminLive.AuditLog do
  use TheBridgeWeb, :live_view

  alias TheBridge.Admin

  @impl true
  def mount(_params, _session, socket) do
    logs = Admin.list_audit_logs(limit: 100)

    {:ok,
     socket
     |> assign(:page_title, "Audit Log")
     |> assign(:logs, logs)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-2xl font-bold">Audit Log</h1>

      <div class="overflow-x-auto">
        <table class="table table-sm">
          <thead>
            <tr>
              <th>Time</th>
              <th>User</th>
              <th>Action</th>
              <th>Resource</th>
              <th>Details</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={log <- @logs}>
              <td class="text-xs">{Calendar.strftime(log.inserted_at, "%b %d %H:%M")}</td>
              <td>{(log.user && log.user.email) || "System"}</td>
              <td><span class="badge badge-sm">{log.action}</span></td>
              <td class="font-mono text-xs">{log.resource_type}/{log.resource_id}</td>
              <td class="text-xs">{inspect(log.metadata)}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div :if={@logs == []} class="text-center py-12 text-base-content/50">
        No audit log entries yet.
      </div>
    </div>
    """
  end
end
