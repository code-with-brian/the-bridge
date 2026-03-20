defmodule TheBridge.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  @types ~w(donation_received need_fulfilled client_update system)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "notifications" do
    field :type, :string
    field :title, :string
    field :body, :string
    field :read_at, :utc_datetime
    field :action_url, :string
    field :metadata, :map, default: %{}

    belongs_to :user, TheBridge.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def types, do: @types

  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:type, :title, :body, :read_at, :action_url, :metadata, :user_id])
    |> validate_required([:type, :title, :user_id])
    |> validate_inclusion(:type, @types)
  end
end
