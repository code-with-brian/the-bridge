defmodule TheBridgeWeb.AdminLive.Vendors do
  use TheBridgeWeb, :live_view

  alias TheBridge.Vendors

  @impl true
  def mount(_params, _session, socket) do
    vendors = Vendors.list_vendors()

    {:ok,
     socket
     |> assign(:page_title, "Manage Vendors")
     |> assign(:vendors, vendors)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex justify-between items-center">
        <h1 class="text-2xl font-bold">Vendors</h1>
        <.link navigate={~p"/admin/vendors/new"} class="btn btn-primary btn-sm">Add Vendor</.link>
      </div>

      <div class="overflow-x-auto">
        <table class="table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Category</th>
              <th>City</th>
              <th>Discount</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={vendor <- @vendors}>
              <td>{vendor.name}</td>
              <td>{vendor.category}</td>
              <td>{vendor.city}</td>
              <td>{(vendor.discount_percentage && "#{vendor.discount_percentage}%") || "—"}</td>
              <td>
                <.link navigate={~p"/admin/vendors/#{vendor.id}/edit"} class="btn btn-ghost btn-xs">
                  Edit
                </.link>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
