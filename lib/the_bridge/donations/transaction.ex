defmodule TheBridge.Donations.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @types ~w(donation refund payout)
  @statuses ~w(succeeded pending failed)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :type, :string
    field :amount_cents, :integer
    field :stripe_id, :string
    field :status, :string, default: "pending"
    field :metadata, :map, default: %{}

    belongs_to :donation, TheBridge.Donations.Donation

    timestamps(type: :utc_datetime)
  end

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:type, :amount_cents, :stripe_id, :status, :metadata, :donation_id])
    |> validate_required([:type, :amount_cents, :status])
    |> validate_inclusion(:type, @types)
    |> validate_inclusion(:status, @statuses)
  end
end
