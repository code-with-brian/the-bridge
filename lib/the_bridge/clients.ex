defmodule TheBridge.Clients do
  @moduledoc """
  The Clients context — manages client profiles, needs, updates, and fulfillments.
  """

  import Ecto.Query, warn: false
  alias TheBridge.Repo
  alias TheBridge.Clients.{Client, Need, Update, Fulfillment, DuplicateDetector}

  # Clients

  def list_clients do
    Client |> where(status: "active") |> order_by(desc: :inserted_at) |> Repo.all()
  end

  def list_clients_for_agency(agency_id) do
    Client
    |> where(agency_id: ^agency_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def get_client!(id),
    do: Repo.get!(Client, id) |> Repo.preload([:agency, :primary_worker, :needs])

  def get_client_by_bridge_id!(bridge_id) do
    Client
    |> Repo.get_by!(bridge_id: bridge_id)
    |> Repo.preload([:agency, :primary_worker, needs: :donations])
  end

  def create_client(attrs) do
    duplicates = DuplicateDetector.check_for_client(attrs)

    result =
      %Client{}
      |> Client.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, client} when duplicates != [] ->
        {:ok, client, duplicates}

      other ->
        other
    end
  end

  def update_client(%Client{} = client, attrs) do
    client
    |> Client.changeset(attrs)
    |> Repo.update()
  end

  def change_client(%Client{} = client, attrs \\ %{}) do
    Client.changeset(client, attrs)
  end

  # Needs

  def list_needs do
    Need
    |> where([n], n.status in ~w(open partially_funded))
    |> order_by(desc: :inserted_at)
    |> preload(:client)
    |> Repo.all()
  end

  def list_needs_for_client(client_id) do
    Need
    |> where(client_id: ^client_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def get_need!(id), do: Repo.get!(Need, id) |> Repo.preload([:client, :created_by, :donations])

  def create_need(attrs) do
    %Need{}
    |> Need.changeset(attrs)
    |> Repo.insert()
  end

  def update_need(%Need{} = need, attrs) do
    need
    |> Need.changeset(attrs)
    |> Repo.update()
  end

  def update_need_funding(%Need{} = need, additional_cents) do
    new_funded = need.funded_cents + additional_cents

    status =
      cond do
        new_funded >= need.amount_cents -> "funded"
        new_funded > 0 -> "partially_funded"
        true -> need.status
      end

    need
    |> Ecto.Changeset.change(funded_cents: new_funded, status: status)
    |> Repo.update()
  end

  def change_need(%Need{} = need, attrs \\ %{}) do
    Need.changeset(need, attrs)
  end

  # Updates

  def list_public_updates_for_client(client_id) do
    Update
    |> where(client_id: ^client_id, public: true)
    |> order_by(desc: :inserted_at)
    |> preload(:author)
    |> Repo.all()
  end

  def list_updates_for_client(client_id) do
    Update
    |> where(client_id: ^client_id)
    |> order_by(desc: :inserted_at)
    |> preload(:author)
    |> Repo.all()
  end

  def create_update(attrs) do
    %Update{}
    |> Update.changeset(attrs)
    |> Repo.insert()
  end

  # Fulfillments

  def create_fulfillment(attrs) do
    %Fulfillment{}
    |> Fulfillment.changeset(attrs)
    |> Repo.insert()
  end

  def list_fulfillments_for_need(need_id) do
    Fulfillment
    |> where(need_id: ^need_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end
end
