defmodule TheBridge.Repo.Migrations.CreateDonationsAndTransactions do
  use Ecto.Migration

  def change do
    create table(:donations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :amount_cents, :integer, null: false
      add :status, :string, null: false, default: "pending"
      add :anonymous, :boolean, default: false
      add :message, :text
      add :stripe_payment_intent_id, :string
      add :stripe_charge_id, :string
      add :receipt_url, :string
      add :need_id, references(:needs, type: :binary_id, on_delete: :restrict), null: false
      add :donor_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      add :client_id, references(:clients, type: :binary_id, on_delete: :restrict)

      timestamps(type: :utc_datetime)
    end

    create index(:donations, [:need_id])
    create index(:donations, [:donor_id])
    create index(:donations, [:client_id])
    create index(:donations, [:stripe_payment_intent_id])

    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false
      add :amount_cents, :integer, null: false
      add :stripe_id, :string
      add :status, :string, null: false, default: "pending"
      add :metadata, :map, default: %{}
      add :donation_id, references(:donations, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:donation_id])
    create index(:transactions, [:stripe_id])
  end
end
