defmodule TheBridge.Workers.DonationReceiptWorker do
  use Oban.Worker, queue: :emails, max_attempts: 3

  alias TheBridge.Donations
  alias TheBridge.Accounts

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"donation_id" => donation_id}}) do
    donation = Donations.get_donation!(donation_id)

    if donation.donor_id do
      donor = Accounts.get_user!(donation.donor_id)

      TheBridge.Accounts.UserNotifier.deliver_donation_receipt(
        donor,
        donation
      )
    end

    :ok
  end
end
