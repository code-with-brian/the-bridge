defmodule TheBridge.Workers.StaleNeedChecker do
  use Oban.Worker, queue: :default, max_attempts: 1

  import Ecto.Query, warn: false
  alias TheBridge.Repo
  alias TheBridge.Clients.Need

  @stale_days 90

  @impl Oban.Worker
  def perform(_job) do
    cutoff = DateTime.add(DateTime.utc_now(), -@stale_days, :day)

    stale_needs =
      Need
      |> where([n], n.status in ~w(open partially_funded))
      |> where([n], n.inserted_at < ^cutoff)
      |> where([n], n.funded_cents == 0)
      |> Repo.all()

    for need <- stale_needs do
      TheBridge.Admin.log("stale_need_flagged", "need", need.id,
        metadata: %{days_open: DateTime.diff(DateTime.utc_now(), need.inserted_at, :day)}
      )
    end

    :ok
  end
end
