defmodule TheBridge.Vendors.Vendor do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "vendors" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :category, :string
    field :website, :string
    field :phone, :string
    field :email, :string
    field :address, :string
    field :city, :string
    field :contact_name, :string
    field :active, :boolean, default: true
    field :logo_url, :string
    field :discount_percentage, :decimal
    field :notes, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(vendor, attrs) do
    vendor
    |> cast(attrs, [
      :name,
      :slug,
      :description,
      :category,
      :website,
      :phone,
      :email,
      :address,
      :city,
      :contact_name,
      :active,
      :logo_url,
      :discount_percentage,
      :notes
    ])
    |> validate_required([:name, :slug])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/)
    |> unique_constraint(:slug)
  end
end
