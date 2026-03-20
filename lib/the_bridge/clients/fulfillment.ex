defmodule TheBridge.Clients.Fulfillment do
  use Ecto.Schema
  import Ecto.Changeset

  @methods ~w(vendor_purchase agency_purchase direct_provision)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "fulfillments" do
    field :amount_cents, :integer
    field :method, :string
    field :receipt_url, :string
    field :notes, :string
    field :confirmed_at, :utc_datetime

    belongs_to :need, TheBridge.Clients.Need
    belongs_to :fulfilled_by, TheBridge.Accounts.User
    belongs_to :vendor, TheBridge.Vendors.Vendor

    timestamps(type: :utc_datetime)
  end

  def methods, do: @methods

  def changeset(fulfillment, attrs) do
    fulfillment
    |> cast(attrs, [
      :amount_cents,
      :method,
      :receipt_url,
      :notes,
      :confirmed_at,
      :need_id,
      :fulfilled_by_id,
      :vendor_id
    ])
    |> validate_required([:amount_cents, :method, :need_id])
    |> validate_inclusion(:method, @methods)
    |> validate_number(:amount_cents, greater_than: 0)
  end
end
