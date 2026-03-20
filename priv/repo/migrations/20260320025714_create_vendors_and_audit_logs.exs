defmodule TheBridge.Repo.Migrations.CreateVendorsAndAuditLogs do
  use Ecto.Migration

  def change do
    create table(:vendors, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text
      add :category, :string
      add :website, :string
      add :phone, :string
      add :email, :string
      add :address, :string
      add :city, :string
      add :contact_name, :string
      add :active, :boolean, default: true
      add :logo_url, :string
      add :discount_percentage, :decimal
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:vendors, [:slug])

    create table(:audit_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :action, :string, null: false
      add :resource_type, :string, null: false
      add :resource_id, :string
      add :metadata, :map, default: %{}
      add :ip_address, :string
      add :user_id, references(:users, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:audit_logs, [:user_id])
    create index(:audit_logs, [:resource_type, :resource_id])
    create index(:audit_logs, [:inserted_at])
  end
end
