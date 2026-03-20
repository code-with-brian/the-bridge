defmodule TheBridge.Workers.WeeklyDigestWorker do
  use Oban.Worker, queue: :emails, max_attempts: 3

  import Ecto.Query, warn: false
  alias TheBridge.Repo
  alias TheBridge.Donations.Donation
  alias TheBridge.Clients.{Need, Update}

  @impl Oban.Worker
  def perform(_job) do
    one_week_ago = DateTime.add(DateTime.utc_now(), -7, :day)

    # Get all donors who donated in the past
    donor_ids =
      Donation
      |> where(status: "completed")
      |> select([d], d.donor_id)
      |> distinct(true)
      |> Repo.all()
      |> Enum.reject(&is_nil/1)

    for donor_id <- donor_ids do
      # Find needs the donor has donated to
      donated_need_ids =
        Donation
        |> where(donor_id: ^donor_id, status: "completed")
        |> select([d], d.need_id)
        |> distinct(true)
        |> Repo.all()

      # Get recent updates on those needs
      updates =
        Update
        |> join(:inner, [u], n in Need, on: u.client_id == n.client_id)
        |> where([u, n], n.id in ^donated_need_ids)
        |> where([u], u.public == true and u.inserted_at > ^one_week_ago)
        |> Repo.all()

      if updates != [] do
        donor = TheBridge.Accounts.get_user!(donor_id)

        TheBridge.Accounts.UserNotifier.deliver_weekly_digest(
          donor,
          updates
        )
      end
    end

    :ok
  end
end
