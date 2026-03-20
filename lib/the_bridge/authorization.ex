defmodule TheBridge.Authorization do
  @moduledoc """
  Policy-based authorization. Returns :ok or {:error, :unauthorized}.

  Usage:
    Authorization.authorize(:manage_clients, user)
    Authorization.authorize(:view_client, user, client)
  """

  alias TheBridge.Accounts.User

  def authorize(action, user, resource \\ nil)

  # Platform admins can do everything
  def authorize(_action, %User{role: "platform_admin"}, _resource), do: :ok

  # Agency management
  def authorize(:manage_agency, %User{role: "agency_admin", agency_id: aid}, %{id: aid})
      when not is_nil(aid),
      do: :ok

  def authorize(:view_agency, %User{agency_id: aid}, %{id: aid})
      when not is_nil(aid),
      do: :ok

  # Client management — agency workers/admins for their own agency
  def authorize(:manage_clients, %User{role: role, agency_id: aid}, _)
      when role in ~w(agency_worker agency_admin) and not is_nil(aid),
      do: :ok

  def authorize(:view_client, %User{role: role, agency_id: aid}, %{agency_id: aid})
      when role in ~w(agency_worker agency_admin) and not is_nil(aid),
      do: :ok

  def authorize(:edit_client, %User{role: role, agency_id: aid}, %{agency_id: aid})
      when role in ~w(agency_worker agency_admin) and not is_nil(aid),
      do: :ok

  # Needs — workers can create/edit needs for clients in their agency
  def authorize(:create_need, %User{role: role, agency_id: aid}, %{agency_id: aid})
      when role in ~w(agency_worker agency_admin) and not is_nil(aid),
      do: :ok

  def authorize(:fulfill_need, %User{role: role, agency_id: aid}, %{agency_id: aid})
      when role in ~w(agency_worker agency_admin) and not is_nil(aid),
      do: :ok

  # Donors can view public client profiles and donate
  def authorize(:donate, %User{role: "donor"}, _), do: :ok
  def authorize(:view_public_client, _user, _), do: :ok
  def authorize(:view_public_need, _user, _), do: :ok

  # Invite workers — agency admins only
  def authorize(:invite_worker, %User{role: "agency_admin", agency_id: aid}, %{id: aid})
      when not is_nil(aid),
      do: :ok

  # Admin actions
  def authorize(:access_admin, %User{role: "platform_admin"}, _), do: :ok
  def authorize(:verify_agency, %User{role: "platform_admin"}, _), do: :ok

  # Default deny
  def authorize(_action, _user, _resource), do: {:error, :unauthorized}
end
