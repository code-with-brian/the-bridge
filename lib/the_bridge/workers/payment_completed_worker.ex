defmodule TheBridge.Workers.PaymentCompletedWorker do
  use Oban.Worker, queue: :payments, max_attempts: 3

  alias TheBridge.Donations
  alias TheBridge.Notifications

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"session_id" => session_id}}) do
    case Stripe.Checkout.Session.retrieve(session_id) do
      {:ok, session} ->
        case Donations.process_completed_checkout(session) do
          {:ok, donation} ->
            notify_donation(donation, session.metadata)
            :ok

          {:error, reason} ->
            {:error, reason}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  defp notify_donation(donation, metadata) do
    # Notify the need's client's agency worker
    need = TheBridge.Clients.get_need!(donation.need_id)
    client = TheBridge.Clients.get_client!(need.client_id)

    if client.primary_worker_id do
      Notifications.create_and_broadcast(%{
        type: "donation_received",
        title: "New donation received",
        body: "A $#{format_cents(donation.amount_cents)} donation was made for #{need.title}",
        action_url: "/agency/clients/#{client.id}",
        user_id: client.primary_worker_id,
        metadata: %{donation_id: donation.id, need_id: need.id}
      })
    end

    # Notify the donor
    if donor_id = metadata["donor_id"] do
      Notifications.create_and_broadcast(%{
        type: "donation_received",
        title: "Thank you for your donation!",
        body:
          "Your $#{format_cents(donation.amount_cents)} donation for #{need.title} has been processed",
        action_url: "/my-donations/#{donation.id}",
        user_id: donor_id,
        metadata: %{donation_id: donation.id}
      })
    end
  end

  defp format_cents(cents), do: :erlang.float_to_binary(cents / 100, decimals: 2)
end
