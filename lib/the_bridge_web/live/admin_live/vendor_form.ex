defmodule TheBridgeWeb.AdminLive.VendorForm do
  use TheBridgeWeb, :live_view

  alias TheBridge.Vendors
  alias TheBridge.Vendors.Vendor

  @impl true
  def mount(params, _session, socket) do
    {vendor, changeset, title} =
      if id = params["id"] do
        vendor = Vendors.get_vendor!(id)
        {vendor, Vendors.change_vendor(vendor), "Edit Vendor"}
      else
        {%Vendor{}, Vendors.change_vendor(%Vendor{}), "New Vendor"}
      end

    {:ok,
     socket
     |> assign(:page_title, title)
     |> assign(:vendor, vendor)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"vendor" => params}, socket) do
    changeset =
      socket.assigns.vendor
      |> Vendors.change_vendor(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"vendor" => params}, socket) do
    save_vendor(socket, socket.assigns.live_action, params)
  end

  defp save_vendor(socket, :new, params) do
    # Auto-generate slug from name
    slug =
      params["name"]
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9]+/, "-")
      |> String.trim("-")

    params = Map.put(params, "slug", slug)

    case Vendors.create_vendor(params) do
      {:ok, _vendor} ->
        {:noreply,
         socket
         |> put_flash(:info, "Vendor created.")
         |> push_navigate(to: ~p"/admin/vendors")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_vendor(socket, :edit, params) do
    case Vendors.update_vendor(socket.assigns.vendor, params) do
      {:ok, _vendor} ->
        {:noreply,
         socket
         |> put_flash(:info, "Vendor updated.")
         |> push_navigate(to: ~p"/admin/vendors")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-lg mx-auto space-y-6">
      <h1 class="text-2xl font-bold">{@page_title}</h1>

      <.form for={@changeset} phx-change="validate" phx-submit="save" class="space-y-4">
        <div class="form-control">
          <label class="label"><span class="label-text">Name *</span></label>
          <input
            type="text"
            name="vendor[name]"
            value={Ecto.Changeset.get_field(@changeset, :name)}
            class="input input-bordered"
            required
          />
        </div>

        <div class="form-control">
          <label class="label"><span class="label-text">Category</span></label>
          <input
            type="text"
            name="vendor[category]"
            value={Ecto.Changeset.get_field(@changeset, :category)}
            class="input input-bordered"
          />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div class="form-control">
            <label class="label"><span class="label-text">City</span></label>
            <input
              type="text"
              name="vendor[city]"
              value={Ecto.Changeset.get_field(@changeset, :city)}
              class="input input-bordered"
            />
          </div>
          <div class="form-control">
            <label class="label"><span class="label-text">Phone</span></label>
            <input
              type="text"
              name="vendor[phone]"
              value={Ecto.Changeset.get_field(@changeset, :phone)}
              class="input input-bordered"
            />
          </div>
        </div>

        <div class="form-control">
          <label class="label"><span class="label-text">Contact Name</span></label>
          <input
            type="text"
            name="vendor[contact_name]"
            value={Ecto.Changeset.get_field(@changeset, :contact_name)}
            class="input input-bordered"
          />
        </div>

        <div class="form-control">
          <label class="label"><span class="label-text">Description</span></label>
          <textarea name="vendor[description]" class="textarea textarea-bordered" rows="3">{Ecto.Changeset.get_field(@changeset, :description)}</textarea>
        </div>

        <div class="form-control">
          <label class="label"><span class="label-text">Discount %</span></label>
          <input
            type="number"
            name="vendor[discount_percentage]"
            value={Ecto.Changeset.get_field(@changeset, :discount_percentage)}
            class="input input-bordered"
            step="0.1"
          />
        </div>

        <div class="flex justify-end gap-2">
          <.link navigate={~p"/admin/vendors"} class="btn btn-ghost">Cancel</.link>
          <button type="submit" class="btn btn-primary">Save Vendor</button>
        </div>
      </.form>
    </div>
    """
  end
end
