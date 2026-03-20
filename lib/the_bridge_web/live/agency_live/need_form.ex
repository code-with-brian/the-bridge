defmodule TheBridgeWeb.AgencyLive.NeedForm do
  use TheBridgeWeb, :live_view

  alias TheBridge.Clients
  alias TheBridge.Clients.Need

  @impl true
  def mount(%{"id" => client_id}, _session, socket) do
    client = Clients.get_client!(client_id)
    changeset = Clients.change_need(%Need{}, %{client_id: client.id})

    {:ok,
     socket
     |> assign(:page_title, "Add Need — #{client.alias_name}")
     |> assign(:client, client)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"need" => params}, socket) do
    changeset =
      %Need{}
      |> Clients.change_need(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"need" => params}, socket) do
    user = socket.assigns.current_scope.user
    client = socket.assigns.client

    # Convert dollars to cents
    amount_cents =
      case Float.parse(params["amount"] || "0") do
        {amount, _} -> round(amount * 100)
        :error -> 0
      end

    need_params =
      Map.merge(params, %{
        "client_id" => client.id,
        "created_by_id" => user.id,
        "amount_cents" => amount_cents
      })

    case Clients.create_need(need_params) do
      {:ok, _need} ->
        {:noreply,
         socket
         |> put_flash(:info, "Need created successfully.")
         |> push_navigate(to: ~p"/agency/clients/#{client.id}")}

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
          <label class="label"><span class="label-text">Title *</span></label>
          <input
            type="text"
            name="need[title]"
            value={Ecto.Changeset.get_field(@changeset, :title)}
            class="input input-bordered"
            required
          />
        </div>

        <div class="form-control">
          <label class="label"><span class="label-text">Description</span></label>
          <textarea name="need[description]" class="textarea textarea-bordered" rows="3">{Ecto.Changeset.get_field(@changeset, :description)}</textarea>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div class="form-control">
            <label class="label"><span class="label-text">Category *</span></label>
            <select name="need[category]" class="select select-bordered" required>
              <option value="">Select...</option>
              <option
                :for={cat <- Need.categories()}
                value={cat}
                selected={Ecto.Changeset.get_field(@changeset, :category) == cat}
              >
                {String.capitalize(cat)}
              </option>
            </select>
          </div>

          <div class="form-control">
            <label class="label"><span class="label-text">Priority *</span></label>
            <select name="need[priority]" class="select select-bordered" required>
              <option
                :for={p <- Need.priorities()}
                value={p}
                selected={Ecto.Changeset.get_field(@changeset, :priority) == p}
              >
                {String.capitalize(p)}
              </option>
            </select>
          </div>
        </div>

        <div class="form-control">
          <label class="label"><span class="label-text">Amount (CAD) *</span></label>
          <label class="input input-bordered flex items-center gap-2">
            $ <input type="number" name="need[amount]" step="0.01" min="0.01" class="grow" required />
          </label>
        </div>

        <div class="flex justify-end gap-2">
          <.link navigate={~p"/agency/clients/#{@client.id}"} class="btn btn-ghost">Cancel</.link>
          <button type="submit" class="btn btn-primary">Create Need</button>
        </div>
      </.form>
    </div>
    """
  end
end
