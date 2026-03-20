defmodule TheBridgeWeb.CheckoutController do
  use TheBridgeWeb, :controller

  alias TheBridge.Donations

  def donate(conn, %{"need_id" => need_id} = params) do
    user = conn.assigns.current_scope.user
    amount_cents = String.to_integer(params["amount_cents"] || "0")

    if amount_cents <= 0 do
      conn
      |> put_flash(:error, "Please enter a valid donation amount.")
      |> redirect(to: ~p"/needs/#{need_id}")
    else
      case Donations.create_checkout_session(need_id, user.id, amount_cents,
             anonymous: params["anonymous"] == "true",
             message: params["message"],
             success_url: url(~p"/my-donations") <> "?success=true",
             cancel_url: url(~p"/needs/#{need_id}")
           ) do
        {:ok, session} ->
          redirect(conn, external: session.url)

        {:error, _error} ->
          conn
          |> put_flash(:error, "Could not create checkout session. Please try again.")
          |> redirect(to: ~p"/needs/#{need_id}")
      end
    end
  end
end
