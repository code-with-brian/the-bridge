defmodule TheBridge.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:agencies, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text
      add :website, :string
      add :phone, :string
      add :email, :string
      add :address, :string
      add :city, :string
      add :province, :string, default: "ON"
      add :postal_code, :string
      add :logo_url, :string
      add :verified, :boolean, default: false
      add :active, :boolean, default: true

      timestamps(type: :utc_datetime)
    end

    create unique_index(:agencies, [:slug])

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :citext, null: false
      add :hashed_password, :string
      add :display_name, :string
      add :avatar_url, :string
      add :phone, :string
      add :role, :string, null: false, default: "donor"
      add :agency_id, references(:agencies, type: :binary_id, on_delete: :nilify_all)
      add :confirmed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create index(:users, [:agency_id])
    create index(:users, [:role])

    create table(:users_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      add :authenticated_at, :utc_datetime

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])

    create table(:agency_invitations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :citext, null: false
      add :role, :string, null: false
      add :token, :string, null: false
      add :accepted_at, :utc_datetime
      add :expires_at, :utc_datetime, null: false
      add :agency_id, references(:agencies, type: :binary_id, on_delete: :delete_all), null: false
      add :invited_by_id, references(:users, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:agency_invitations, [:token])
    create index(:agency_invitations, [:agency_id])
    create index(:agency_invitations, [:email])
  end
end
