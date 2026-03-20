defmodule TheBridgeWeb.AgencyLive.Workers do
  use TheBridgeWeb, :live_view

  alias TheBridge.Agencies

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    agency = Agencies.get_agency!(user.agency_id)
    workers = Agencies.list_agency_workers(agency)
    invitations = Agencies.list_agency_invitations(agency)

    {:ok,
     socket
     |> assign(:page_title, "Workers — #{agency.name}")
     |> assign(:agency, agency)
     |> assign(:workers, workers)
     |> assign(:invitations, invitations)
     |> assign(:show_invite_form, false)
     |> assign(:invite_email, "")
     |> assign(:invite_role, "agency_worker")}
  end

  @impl true
  def handle_event("toggle_invite", _, socket) do
    {:noreply, assign(socket, :show_invite_form, !socket.assigns.show_invite_form)}
  end

  def handle_event("invite", %{"email" => email, "role" => role}, socket) do
    user = socket.assigns.current_scope.user

    case Agencies.create_invitation(socket.assigns.agency, user, %{email: email, role: role}) do
      {:ok, _invitation} ->
        invitations = Agencies.list_agency_invitations(socket.assigns.agency)

        {:noreply,
         socket
         |> put_flash(:info, "Invitation sent to #{email}")
         |> assign(:invitations, invitations)
         |> assign(:show_invite_form, false)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create invitation.")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex justify-between items-center">
        <h1 class="text-2xl font-bold">Workers</h1>
        <button phx-click="toggle_invite" class="btn btn-primary btn-sm">
          Invite Worker
        </button>
      </div>

      <form :if={@show_invite_form} phx-submit="invite" class="card bg-base-200 p-4 space-y-3">
        <div class="form-control">
          <input
            type="email"
            name="email"
            placeholder="worker@email.com"
            class="input input-bordered"
            required
          />
        </div>
        <div class="form-control">
          <select name="role" class="select select-bordered">
            <option value="agency_worker">Worker</option>
            <option value="agency_admin">Admin</option>
          </select>
        </div>
        <button type="submit" class="btn btn-primary btn-sm">Send Invitation</button>
      </form>

      <div class="overflow-x-auto">
        <table class="table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Role</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={worker <- @workers}>
              <td>{worker.display_name || "—"}</td>
              <td>{worker.email}</td>
              <td><span class="badge">{worker.role}</span></td>
            </tr>
          </tbody>
        </table>
      </div>

      <section :if={@invitations != []}>
        <h2 class="text-lg font-bold mb-3">Pending Invitations</h2>
        <div
          :for={inv <- @invitations}
          class="flex justify-between items-center py-2 border-b border-base-300"
        >
          <span>{inv.email}</span>
          <div class="flex gap-2">
            <span class="badge">{inv.role}</span>
            <span :if={inv.accepted_at} class="badge badge-success">Accepted</span>
            <span :if={!inv.accepted_at} class="badge badge-warning">Pending</span>
          </div>
        </div>
      </section>
    </div>
    """
  end
end
