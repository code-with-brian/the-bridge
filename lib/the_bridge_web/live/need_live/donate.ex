defmodule TheBridgeWeb.NeedLive.Donate do
  use TheBridgeWeb, :live_view

  alias TheBridge.Clients

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    need = Clients.get_need!(id)
    remaining = need.amount_cents - need.funded_cents

    {:ok,
     socket
     |> assign(:page_title, "Donate — #{need.title}")
     |> assign(:need, need)
     |> assign(:remaining_cents, remaining)
     |> assign(:amount, "")
     |> assign(:message, "")
     |> assign(:anonymous, false)}
  end

  @impl true
  def handle_event("validate", params, socket) do
    {:noreply,
     socket
     |> assign(:amount, params["amount"] || "")
     |> assign(:message, params["message"] || "")
     |> assign(:anonymous, params["anonymous"] == "true")}
  end

  @impl true
  def handle_event("donate", params, socket) do
    user = socket.assigns.current_scope && socket.assigns.current_scope.user

    if is_nil(user) do
      {:noreply,
       socket
       |> put_flash(:error, "Please log in to donate.")
       |> push_navigate(to: ~p"/users/log-in")}
    else
      amount_dollars = params["amount"] || "0"

      case Float.parse(amount_dollars) do
        {amount, _} when amount > 0 ->
          amount_cents = round(amount * 100)
          need = socket.assigns.need

          redirect_url =
            ~p"/checkout/donate/#{need.id}?amount_cents=#{amount_cents}&anonymous=#{params["anonymous"] || "false"}&message=#{params["message"] || ""}"

          {:noreply, push_navigate(socket, to: redirect_url)}

        _ ->
          {:noreply, put_flash(socket, :error, "Please enter a valid amount.")}
      end
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-lg mx-auto space-y-6">
      <.link navigate={~p"/needs/#{@need.id}"} class="btn btn-ghost btn-sm">
        &larr; Back
      </.link>

      <h1 class="text-2xl font-bold">Donate to: {@need.title}</h1>
      <p class="text-base-content/70">
        ${format_cents(@remaining_cents)} still needed
      </p>

      <form phx-submit="donate" phx-change="validate" class="space-y-4">
        <div class="form-control">
          <label class="label">
            <span class="label-text">Amount (CAD)</span>
          </label>
          <label class="input input-bordered flex items-center gap-2">
            $
            <input
              type="number"
              name="amount"
              value={@amount}
              step="0.01"
              min="1"
              placeholder="25.00"
              class="grow"
              required
            />
          </label>
        </div>

        <div class="form-control">
          <label class="label">
            <span class="label-text">Message (optional)</span>
          </label>
          <textarea
            name="message"
            class="textarea textarea-bordered"
            placeholder="Add an encouraging message..."
            rows="2"
          >{@message}</textarea>
        </div>

        <div class="form-control">
          <label class="label cursor-pointer justify-start gap-3">
            <input
              type="checkbox"
              name="anonymous"
              value="true"
              checked={@anonymous}
              class="checkbox"
            />
            <span class="label-text">Make this donation anonymous</span>
          </label>
        </div>

        <button type="submit" class="btn btn-primary w-full">
          Continue to Payment
        </button>

        <p class="text-xs text-base-content/50 text-center">
          You'll be redirected to Stripe for secure payment processing.
        </p>
      </form>
    </div>
    """
  end

  defp format_cents(cents) when is_integer(cents) do
    :erlang.float_to_binary(cents / 100, decimals: 2)
  end

  defp format_cents(_), do: "0.00"
end
