defmodule TheBridge.Admin do
  @moduledoc """
  The Admin context — audit logging, moderation, platform health.
  """

  import Ecto.Query, warn: false
  alias TheBridge.Repo
  alias TheBridge.Admin.AuditLog

  def log(action, resource_type, resource_id \\ nil, opts \\ []) do
    %AuditLog{}
    |> AuditLog.changeset(%{
      action: action,
      resource_type: resource_type,
      resource_id: resource_id && to_string(resource_id),
      metadata: Keyword.get(opts, :metadata, %{}),
      ip_address: Keyword.get(opts, :ip_address),
      user_id: Keyword.get(opts, :user_id)
    })
    |> Repo.insert()
  end

  def list_audit_logs(opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    AuditLog
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
    |> preload(:user)
    |> Repo.all()
  end

  def list_audit_logs_for_resource(resource_type, resource_id) do
    AuditLog
    |> where(resource_type: ^resource_type, resource_id: ^to_string(resource_id))
    |> order_by(desc: :inserted_at)
    |> preload(:user)
    |> Repo.all()
  end
end
