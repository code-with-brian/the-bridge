defmodule TheBridge.Donations.Donation do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(pending completed refunded failed)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "donations" do
    field :amount_cents, :integer
    field :status, :string, default: "pending"
    field :anonymous, :boolean, default: false
    field :message, :string
    field :stripe_payment_intent_id, :string
    field :stripe_charge_id, :string
    field :receipt_url, :string

    belongs_to :need, TheBridge.Clients.Need
    belongs_to :donor, TheBridge.Accounts.User
    belongs_to :client, TheBridge.Clients.Client

    timestamps(type: :utc_datetime)
  end

  def statuses, do: @statuses

  def changeset(donation, attrs) do
    donation
    |> cast(attrs, [
      :amount_cents,
      :status,
      :anonymous,
      :message,
      :stripe_payment_intent_id,
      :stripe_charge_id,
      :receipt_url,
      :need_id,
      :donor_id,
      :client_id
    ])
    |> validate_required([:amount_cents, :need_id])
    |> validate_inclusion(:status, @statuses)
    |> validate_number(:amount_cents, greater_than: 0)
  end
end
