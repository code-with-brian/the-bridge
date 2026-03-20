defmodule TheBridge.Clients.Client do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(active housed inactive archived)
  @housing_statuses ~w(unsheltered emergency_shelter transitional recently_housed)
  @age_ranges ~w(18-24 25-34 35-44 45-54 55-64 65+)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "clients" do
    field :bridge_id, :string
    field :first_name, :string
    field :last_name, :string
    field :alias_name, :string
    field :date_of_birth, :date
    field :birth_year, :integer
    field :initials, :string
    field :story, :string
    field :photo_url, :string
    field :gender, :string
    field :age_range, :string
    field :status, :string, default: "active"
    field :housing_status, :string
    field :consent_signed, :boolean, default: false
    field :consent_signed_at, :utc_datetime
    field :notes, :string

    belongs_to :agency, TheBridge.Agencies.Agency
    belongs_to :primary_worker, TheBridge.Accounts.User
    has_many :needs, TheBridge.Clients.Need
    has_many :updates, TheBridge.Clients.Update

    timestamps(type: :utc_datetime)
  end

  def statuses, do: @statuses
  def housing_statuses, do: @housing_statuses
  def age_ranges, do: @age_ranges

  def changeset(client, attrs) do
    client
    |> cast(attrs, [
      :first_name,
      :last_name,
      :alias_name,
      :date_of_birth,
      :birth_year,
      :story,
      :photo_url,
      :gender,
      :age_range,
      :status,
      :housing_status,
      :consent_signed,
      :consent_signed_at,
      :notes,
      :agency_id,
      :primary_worker_id
    ])
    |> validate_required([:first_name, :last_name, :alias_name, :agency_id])
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:housing_status, @housing_statuses ++ [nil])
    |> validate_inclusion(:age_range, @age_ranges ++ [nil])
    |> derive_fields()
    |> maybe_generate_bridge_id()
  end

  defp derive_fields(changeset) do
    changeset
    |> derive_initials()
    |> derive_birth_year()
    |> derive_age_range()
  end

  defp derive_initials(changeset) do
    first = get_field(changeset, :first_name)
    last = get_field(changeset, :last_name)

    if first && last do
      initials = (String.first(first) <> String.first(last)) |> String.upcase()
      put_change(changeset, :initials, initials)
    else
      changeset
    end
  end

  defp derive_birth_year(changeset) do
    case get_change(changeset, :date_of_birth) do
      nil -> changeset
      dob -> put_change(changeset, :birth_year, dob.year)
    end
  end

  defp derive_age_range(changeset) do
    case get_field(changeset, :date_of_birth) do
      nil ->
        changeset

      dob ->
        age = Date.diff(Date.utc_today(), dob) |> div(365)

        range =
          cond do
            age < 25 -> "18-24"
            age < 35 -> "25-34"
            age < 45 -> "35-44"
            age < 55 -> "45-54"
            age < 65 -> "55-64"
            true -> "65+"
          end

        put_change(changeset, :age_range, range)
    end
  end

  defp maybe_generate_bridge_id(changeset) do
    if get_field(changeset, :bridge_id) do
      changeset
    else
      id =
        "BRG-" <>
          (:crypto.strong_rand_bytes(4) |> Base.encode32(padding: false) |> String.slice(0, 6))

      put_change(changeset, :bridge_id, id)
    end
  end
end
