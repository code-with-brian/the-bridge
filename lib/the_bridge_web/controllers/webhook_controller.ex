defmodule TheBridgeWeb.WebhookController do
  use TheBridgeWeb, :controller

  def stripe(conn, _params) do
    with [signature] <- get_req_header(conn, "stripe-signature"),
         {:ok, %Stripe.Event{} = event} <-
           Stripe.Webhook.construct_event(
             conn.assigns.raw_body,
             signature,
             Application.get_env(:stripity_stripe, :signing_secret)
           ) do
      handle_event(event)
      json(conn, %{status: "ok"})
    else
      _ ->
        conn
        |> put_status(400)
        |> json(%{error: "Invalid webhook"})
    end
  end

  defp handle_event(%Stripe.Event{type: "checkout.session.completed", data: %{object: session}}) do
    %{session_id: session.id}
    |> TheBridge.Workers.PaymentCompletedWorker.new()
    |> Oban.insert()
  end

  defp handle_event(_event), do: :ok
end
