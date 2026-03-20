defmodule TheBridgeWeb.AdminLive.Users do
  use TheBridgeWeb, :live_view

  alias TheBridge.Accounts

  @impl true
  def mount(_params, _session, socket) do
    users = Accounts.list_users()

    {:ok,
     socket
     |> assign(:page_title, "Manage Users")
     |> assign(:users, users)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-2xl font-bold">Users</h1>

      <div class="overflow-x-auto">
        <table class="table">
          <thead>
            <tr>
              <th>Email</th>
              <th>Name</th>
              <th>Role</th>
              <th>Confirmed</th>
              <th>Joined</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={user <- @users}>
              <td>{user.email}</td>
              <td>{user.display_name || "—"}</td>
              <td><span class="badge">{user.role}</span></td>
              <td>{if user.confirmed_at, do: "Yes", else: "No"}</td>
              <td>{Calendar.strftime(user.inserted_at, "%b %d, %Y")}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
