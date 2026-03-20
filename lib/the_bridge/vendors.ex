defmodule TheBridge.Vendors do
  @moduledoc """
  The Vendors context.
  """

  import Ecto.Query, warn: false
  alias TheBridge.Repo
  alias TheBridge.Vendors.Vendor

  def list_vendors do
    Vendor |> where(active: true) |> order_by(:name) |> Repo.all()
  end

  def list_vendors_by_category(category) do
    Vendor |> where(active: true, category: ^category) |> order_by(:name) |> Repo.all()
  end

  def get_vendor!(id), do: Repo.get!(Vendor, id)

  def create_vendor(attrs) do
    %Vendor{}
    |> Vendor.changeset(attrs)
    |> Repo.insert()
  end

  def update_vendor(%Vendor{} = vendor, attrs) do
    vendor
    |> Vendor.changeset(attrs)
    |> Repo.update()
  end

  def delete_vendor(%Vendor{} = vendor) do
    Repo.delete(vendor)
  end

  def change_vendor(%Vendor{} = vendor, attrs \\ %{}) do
    Vendor.changeset(vendor, attrs)
  end

  def search_vendors(query) do
    search = "%#{query}%"

    Vendor
    |> where(active: true)
    |> where([v], ilike(v.name, ^search) or ilike(v.description, ^search))
    |> order_by(:name)
    |> Repo.all()
  end
end
