defmodule TheBridge.Clients.Update do
  use Ecto.Schema
  import Ecto.Changeset

  @update_types ~w(progress milestone note status_change)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "client_updates" do
    field :body, :string
    field :update_type, :string
    field :public, :boolean, default: false
    field :previous_status, :string
    field :new_status, :string

    belongs_to :client, TheBridge.Clients.Client
    belongs_to :author, TheBridge.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def update_types, do: @update_types

  def changeset(update, attrs) do
    update
    |> cast(attrs, [
      :body,
      :update_type,
      :public,
      :previous_status,
      :new_status,
      :client_id,
      :author_id
    ])
    |> validate_required([:body, :update_type, :client_id])
    |> validate_inclusion(:update_type, @update_types)
  end
end
