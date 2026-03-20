defmodule TheBridge.Agencies.Agency do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "agencies" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :website, :string
    field :phone, :string
    field :email, :string
    field :address, :string
    field :city, :string
    field :province, :string, default: "ON"
    field :postal_code, :string
    field :logo_url, :string
    field :verified, :boolean, default: false
    field :active, :boolean, default: true

    has_many :users, TheBridge.Accounts.User
    has_many :clients, TheBridge.Clients.Client
    has_many :invitations, TheBridge.Agencies.Invitation

    timestamps(type: :utc_datetime)
  end

  def changeset(agency, attrs) do
    agency
    |> cast(attrs, [
      :name,
      :slug,
      :description,
      :website,
      :phone,
      :email,
      :address,
      :city,
      :province,
      :postal_code,
      :logo_url,
      :verified,
      :active
    ])
    |> validate_required([:name, :slug])
    |> validate_length(:name, min: 2, max: 100)
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "must be lowercase alphanumeric with dashes"
    )
    |> unique_constraint(:slug)
    |> maybe_generate_slug()
  end

  defp maybe_generate_slug(changeset) do
    case get_change(changeset, :slug) do
      nil ->
        if name = get_change(changeset, :name) do
          slug =
            name |> String.downcase() |> String.replace(~r/[^a-z0-9]+/, "-") |> String.trim("-")

          put_change(changeset, :slug, slug)
        else
          changeset
        end

      _ ->
        changeset
    end
  end
end
