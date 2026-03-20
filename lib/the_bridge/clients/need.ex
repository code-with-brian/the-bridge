defmodule TheBridge.Clients.Need do
  use Ecto.Schema
  import Ecto.Changeset

  @categories ~w(clothing food transit hygiene medical housing education employment documents other)
  @priorities ~w(urgent high normal low)
  @statuses ~w(open partially_funded funded in_progress fulfilled cancelled)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "needs" do
    field :title, :string
    field :description, :string
    field :category, :string
    field :priority, :string, default: "normal"
    field :status, :string, default: "open"
    field :amount_cents, :integer
    field :funded_cents, :integer, default: 0
    field :fulfilled_at, :utc_datetime
    field :expires_at, :utc_datetime
    field :vendor_notes, :string

    belongs_to :client, TheBridge.Clients.Client
    belongs_to :created_by, TheBridge.Accounts.User
    has_many :donations, TheBridge.Donations.Donation
    has_many :fulfillments, TheBridge.Clients.Fulfillment

    timestamps(type: :utc_datetime)
  end

  def categories, do: @categories
  def priorities, do: @priorities
  def statuses, do: @statuses

  def changeset(need, attrs) do
    need
    |> cast(attrs, [
      :title,
      :description,
      :category,
      :priority,
      :status,
      :amount_cents,
      :funded_cents,
      :fulfilled_at,
      :expires_at,
      :vendor_notes,
      :client_id,
      :created_by_id
    ])
    |> validate_required([:title, :category, :amount_cents, :client_id])
    |> validate_inclusion(:category, @categories)
    |> validate_inclusion(:priority, @priorities)
    |> validate_inclusion(:status, @statuses)
    |> validate_number(:amount_cents, greater_than: 0)
  end

  def funding_status(%__MODULE__{funded_cents: funded, amount_cents: amount}) do
    cond do
      funded >= amount -> :funded
      funded > 0 -> :partially_funded
      true -> :open
    end
  end

  def funding_percentage(%__MODULE__{funded_cents: funded, amount_cents: amount}) do
    if amount > 0, do: min(round(funded / amount * 100), 100), else: 0
  end
end
