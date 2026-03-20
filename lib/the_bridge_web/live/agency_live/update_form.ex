defmodule TheBridgeWeb.AgencyLive.UpdateForm do
  use TheBridgeWeb, :live_view

  alias TheBridge.Clients
  alias TheBridge.Clients.Update

  @impl true
  def mount(%{"id" => client_id}, _session, socket) do
    client = Clients.get_client!(client_id)

    {:ok,
     socket
     |> assign(:page_title, "Add Update — #{client.alias_name}")
     |> assign(:client, client)}
  end

  @impl true
  def handle_event("save", %{"update" => params}, socket) do
    user = socket.assigns.current_scope.user
    client = socket.assigns.client

    update_params =
      Map.merge(params, %{
        "client_id" => client.id,
        "author_id" => user.id
      })

    case Clients.create_update(update_params) do
      {:ok, _update} ->
        {:noreply,
         socket
         |> put_flash(:info, "Update added.")
         |> push_navigate(to: ~p"/agency/clients/#{client.id}")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create update.")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-lg mx-auto space-y-6">
      <h1 class="text-2xl font-bold">{@page_title}</h1>

      <form phx-submit="save" class="space-y-4">
        <div class="form-control">
          <label class="label"><span class="label-text">Update Type *</span></label>
          <select name="update[update_type]" class="select select-bordered" required>
            <option :for={type <- Update.update_types()} value={type}>
              {humanize(type)}
            </option>
          </select>
        </div>

        <div class="form-control">
          <label class="label"><span class="label-text">Content *</span></label>
          <textarea name="update[body]" class="textarea textarea-bordered" rows="4" required></textarea>
        </div>

        <div class="form-control">
          <label class="label cursor-pointer justify-start gap-3">
            <input type="checkbox" name="update[public]" value="true" class="checkbox" />
            <span class="label-text">Make this update visible to donors</span>
          </label>
        </div>

        <div class="flex justify-end gap-2">
          <.link navigate={~p"/agency/clients/#{@client.id}"} class="btn btn-ghost">Cancel</.link>
          <button type="submit" class="btn btn-primary">Save Update</button>
        </div>
      </form>
    </div>
    """
  end

  defp humanize(str), do: str |> String.replace("_", " ") |> String.capitalize()
end
