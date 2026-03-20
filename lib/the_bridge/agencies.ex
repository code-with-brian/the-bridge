defmodule TheBridge.Agencies do
  @moduledoc """
  The Agencies context — CRUD for agencies and invitations.
  """

  import Ecto.Query, warn: false
  alias TheBridge.Repo
  alias TheBridge.Agencies.{Agency, Invitation}
  alias TheBridge.Accounts.User

  # Agencies

  def list_agencies do
    Agency |> order_by(:name) |> Repo.all()
  end

  def list_active_agencies do
    Agency |> where(active: true) |> order_by(:name) |> Repo.all()
  end

  def list_verified_agencies do
    Agency |> where(active: true, verified: true) |> order_by(:name) |> Repo.all()
  end

  def get_agency!(id), do: Repo.get!(Agency, id)

  def get_agency_by_slug!(slug), do: Repo.get_by!(Agency, slug: slug)

  def create_agency(attrs) do
    %Agency{}
    |> Agency.changeset(attrs)
    |> Repo.insert()
  end

  def update_agency(%Agency{} = agency, attrs) do
    agency
    |> Agency.changeset(attrs)
    |> Repo.update()
  end

  def verify_agency(%Agency{} = agency) do
    agency
    |> Ecto.Changeset.change(verified: true)
    |> Repo.update()
  end

  def delete_agency(%Agency{} = agency) do
    Repo.delete(agency)
  end

  def change_agency(%Agency{} = agency, attrs \\ %{}) do
    Agency.changeset(agency, attrs)
  end

  # Workers

  def list_agency_workers(%Agency{id: agency_id}) do
    User
    |> where(agency_id: ^agency_id)
    |> where([u], u.role in ~w(agency_worker agency_admin))
    |> order_by(:display_name)
    |> Repo.all()
  end

  # Invitations

  def create_invitation(%Agency{} = agency, %User{} = invited_by, attrs) do
    %Invitation{}
    |> Invitation.changeset(
      Map.merge(attrs, %{
        agency_id: agency.id,
        invited_by_id: invited_by.id,
        expires_at: DateTime.add(DateTime.utc_now(), 7, :day)
      })
    )
    |> Repo.insert()
  end

  def get_invitation_by_token(token) do
    Invitation
    |> where(token: ^token)
    |> Repo.one()
    |> Repo.preload(:agency)
  end

  def accept_invitation(%Invitation{} = invitation, %User{} = user) do
    if Invitation.expired?(invitation) do
      {:error, :expired}
    else
      if Invitation.accepted?(invitation) do
        {:error, :already_accepted}
      else
        Repo.transact(fn ->
          with {:ok, invitation} <-
                 invitation
                 |> Ecto.Changeset.change(accepted_at: DateTime.utc_now(:second))
                 |> Repo.update(),
               {:ok, user} <-
                 user
                 |> User.role_changeset(%{role: invitation.role, agency_id: invitation.agency_id})
                 |> Repo.update() do
            {:ok, %{invitation: invitation, user: user}}
          end
        end)
      end
    end
  end

  def list_agency_invitations(%Agency{id: agency_id}) do
    Invitation
    |> where(agency_id: ^agency_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end
end
