defmodule TheBridge.Repo.Migrations.CreateClientsAndNeeds do
  use Ecto.Migration

  def change do
    create table(:clients, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :bridge_id, :string, null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :alias_name, :string, null: false
      add :date_of_birth, :date
      add :birth_year, :integer
      add :initials, :string
      add :story, :text
      add :photo_url, :string
      add :gender, :string
      add :age_range, :string
      add :status, :string, null: false, default: "active"
      add :housing_status, :string
      add :consent_signed, :boolean, default: false
      add :consent_signed_at, :utc_datetime
      add :notes, :text
      add :agency_id, references(:agencies, type: :binary_id, on_delete: :restrict), null: false
      add :primary_worker_id, references(:users, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:clients, [:bridge_id])
    create index(:clients, [:agency_id])
    create index(:clients, [:primary_worker_id])
    create index(:clients, [:status])
    create index(:clients, [:initials, :birth_year])

    create table(:needs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :description, :text
      add :category, :string, null: false
      add :priority, :string, null: false, default: "normal"
      add :status, :string, null: false, default: "open"
      add :amount_cents, :integer, null: false
      add :funded_cents, :integer, null: false, default: 0
      add :fulfilled_at, :utc_datetime
      add :expires_at, :utc_datetime
      add :vendor_notes, :text
      add :client_id, references(:clients, type: :binary_id, on_delete: :delete_all), null: false
      add :created_by_id, references(:users, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:needs, [:client_id])
    create index(:needs, [:status])
    create index(:needs, [:category])
    create index(:needs, [:priority])

    create table(:client_updates, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :body, :text, null: false
      add :update_type, :string, null: false
      add :public, :boolean, default: false
      add :previous_status, :string
      add :new_status, :string
      add :client_id, references(:clients, type: :binary_id, on_delete: :delete_all), null: false
      add :author_id, references(:users, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:client_updates, [:client_id])

    create table(:fulfillments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :amount_cents, :integer, null: false
      add :method, :string, null: false
      add :receipt_url, :string
      add :notes, :text
      add :confirmed_at, :utc_datetime
      add :need_id, references(:needs, type: :binary_id, on_delete: :delete_all), null: false
      add :fulfilled_by_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      add :vendor_id, :binary_id

      timestamps(type: :utc_datetime)
    end

    create index(:fulfillments, [:need_id])
  end
end
