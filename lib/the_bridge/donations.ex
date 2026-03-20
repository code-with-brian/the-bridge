defmodule TheBridge.Donations do
  @moduledoc """
  The Donations context — manages donations, Stripe checkout, and transactions.
  """

  import Ecto.Query, warn: false
  alias TheBridge.Repo
  alias TheBridge.Donations.{Donation, Transaction}
  alias TheBridge.Clients

  def get_donation!(id), do: Repo.get!(Donation, id) |> Repo.preload([:need, :donor, :client])

  def list_donations_for_donor(donor_id) do
    Donation
    |> where(donor_id: ^donor_id)
    |> where([d], d.status == "completed")
    |> order_by(desc: :inserted_at)
    |> preload(:need)
    |> Repo.all()
  end

  def list_donations_for_need(need_id) do
    Donation
    |> where(need_id: ^need_id)
    |> where([d], d.status == "completed")
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def create_checkout_session(need_id, donor_id, amount_cents, opts \\ []) do
    need = Clients.get_need!(need_id)
    anonymous = Keyword.get(opts, :anonymous, false)
    message = Keyword.get(opts, :message)
    success_url = Keyword.get(opts, :success_url, "http://localhost:4000/my-donations")
    cancel_url = Keyword.get(opts, :cancel_url, "http://localhost:4000/needs/#{need_id}")

    params = %{
      mode: "payment",
      payment_method_types: ["card"],
      line_items: [
        %{
          price_data: %{
            currency: "cad",
            unit_amount: amount_cents,
            product_data: %{
              name: "Donation: #{need.title}",
              description: "Supporting a need through The Bridge"
            }
          },
          quantity: 1
        }
      ],
      success_url: success_url,
      cancel_url: cancel_url,
      metadata: %{
        need_id: need_id,
        donor_id: donor_id,
        client_id: need.client_id,
        anonymous: to_string(anonymous),
        message: message || ""
      }
    }

    Stripe.Checkout.Session.create(params)
  end

  def process_completed_checkout(session) do
    metadata = session.metadata

    Repo.transact(fn ->
      with {:ok, donation} <-
             %Donation{}
             |> Donation.changeset(%{
               amount_cents: session.amount_total,
               status: "completed",
               anonymous: metadata["anonymous"] == "true",
               message: if(metadata["message"] != "", do: metadata["message"]),
               stripe_payment_intent_id: session.payment_intent,
               need_id: metadata["need_id"],
               donor_id: metadata["donor_id"],
               client_id: metadata["client_id"]
             })
             |> Repo.insert(),
           {:ok, _transaction} <-
             %Transaction{}
             |> Transaction.changeset(%{
               type: "donation",
               amount_cents: session.amount_total,
               stripe_id: session.payment_intent,
               status: "succeeded",
               donation_id: donation.id
             })
             |> Repo.insert(),
           {:ok, _need} <-
             Clients.update_need_funding(
               Clients.get_need!(metadata["need_id"]),
               session.amount_total
             ) do
        {:ok, donation}
      end
    end)
  end

  def donor_total_donated(donor_id) do
    Donation
    |> where(donor_id: ^donor_id, status: "completed")
    |> select([d], sum(d.amount_cents))
    |> Repo.one() || 0
  end

  def donor_donation_count(donor_id) do
    Donation
    |> where(donor_id: ^donor_id, status: "completed")
    |> Repo.aggregate(:count)
  end
end
