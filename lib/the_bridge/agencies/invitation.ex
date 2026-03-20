defmodule TheBridge.Agencies.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "agency_invitations" do
    field :email, :string
    field :role, :string
    field :token, :string
    field :accepted_at, :utc_datetime
    field :expires_at, :utc_datetime

    belongs_to :agency, TheBridge.Agencies.Agency
    belongs_to :invited_by, TheBridge.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:email, :role, :agency_id, :invited_by_id, :expires_at])
    |> validate_required([:email, :role, :agency_id, :expires_at])
    |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/)
    |> validate_inclusion(:role, ~w(agency_worker agency_admin))
    |> put_token()
  end

  defp put_token(changeset) do
    if get_field(changeset, :token) do
      changeset
    else
      put_change(changeset, :token, :crypto.strong_rand_bytes(32) |> Base.url_encode64())
    end
  end

  def expired?(%__MODULE__{expires_at: expires_at}) do
    DateTime.compare(DateTime.utc_now(), expires_at) == :gt
  end

  def accepted?(%__MODULE__{accepted_at: accepted_at}) do
    not is_nil(accepted_at)
  end
end
