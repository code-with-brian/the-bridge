defmodule TheBridge.Notifications do
  @moduledoc """
  The Notifications context — create, broadcast, and manage notifications.
  """

  import Ecto.Query, warn: false
  alias TheBridge.Repo
  alias TheBridge.Notifications.Notification

  def list_notifications(user_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 20)

    Notification
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  def unread_count(user_id) do
    Notification
    |> where(user_id: ^user_id)
    |> where([n], is_nil(n.read_at))
    |> Repo.aggregate(:count)
  end

  def create_and_broadcast(attrs) do
    with {:ok, notification} <-
           %Notification{}
           |> Notification.changeset(attrs)
           |> Repo.insert() do
      Phoenix.PubSub.broadcast(
        TheBridge.PubSub,
        "user_notifications:#{notification.user_id}",
        {:new_notification, notification}
      )

      {:ok, notification}
    end
  end

  def mark_read(%Notification{} = notification) do
    notification
    |> Ecto.Changeset.change(read_at: DateTime.utc_now(:second))
    |> Repo.update()
  end

  def mark_all_read(user_id) do
    now = DateTime.utc_now(:second)

    Notification
    |> where(user_id: ^user_id)
    |> where([n], is_nil(n.read_at))
    |> Repo.update_all(set: [read_at: now])
  end
end
