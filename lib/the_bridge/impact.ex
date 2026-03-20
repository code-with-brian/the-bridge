defmodule TheBridge.Impact do
  @moduledoc """
  Read-only query module for impact/transparency metrics.
  """

  import Ecto.Query, warn: false
  alias TheBridge.Repo
  alias TheBridge.Donations.Donation
  alias TheBridge.Clients.{Client, Need}

  def platform_stats do
    %{
      total_donated_cents: total_donated(),
      total_donors: total_donors(),
      total_clients_served: total_clients_served(),
      total_needs_fulfilled: total_needs_fulfilled(),
      needs_open: needs_by_status("open") + needs_by_status("partially_funded")
    }
  end

  def agency_stats(agency_id) do
    clients = Client |> where(agency_id: ^agency_id) |> select([c], c.id) |> Repo.all()

    needs_query = Need |> where([n], n.client_id in ^clients)

    %{
      total_clients: length(clients),
      total_needs: Repo.aggregate(needs_query, :count),
      total_funded_cents: needs_query |> select([n], sum(n.funded_cents)) |> Repo.one() || 0,
      fulfilled_count: needs_query |> where(status: "fulfilled") |> Repo.aggregate(:count)
    }
  end

  def donor_impact(donor_id) do
    donations =
      Donation
      |> where(donor_id: ^donor_id, status: "completed")
      |> Repo.all()

    %{
      total_donated_cents: Enum.sum(Enum.map(donations, & &1.amount_cents)),
      donation_count: length(donations),
      needs_supported: donations |> Enum.map(& &1.need_id) |> Enum.uniq() |> length(),
      clients_helped:
        donations |> Enum.map(& &1.client_id) |> Enum.uniq() |> Enum.reject(&is_nil/1) |> length()
    }
  end

  def category_breakdown do
    Need
    |> group_by(:category)
    |> select([n], %{category: n.category, count: count(n.id), funded_cents: sum(n.funded_cents)})
    |> Repo.all()
  end

  def fulfillment_rate do
    total = Repo.aggregate(Need, :count)
    fulfilled = Need |> where(status: "fulfilled") |> Repo.aggregate(:count)

    if total > 0, do: round(fulfilled / total * 100), else: 0
  end

  # Private helpers

  defp total_donated do
    Donation
    |> where(status: "completed")
    |> select([d], sum(d.amount_cents))
    |> Repo.one() || 0
  end

  defp total_donors do
    Donation
    |> where(status: "completed")
    |> select([d], count(d.donor_id, :distinct))
    |> Repo.one() || 0
  end

  defp total_clients_served do
    Client
    |> where([c], c.status in ~w(active housed))
    |> Repo.aggregate(:count)
  end

  defp total_needs_fulfilled do
    Need
    |> where(status: "fulfilled")
    |> Repo.aggregate(:count)
  end

  defp needs_by_status(status) do
    Need
    |> where(status: ^status)
    |> Repo.aggregate(:count)
  end
end
