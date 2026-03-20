defmodule TheBridge.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @roles ~w(donor agency_worker agency_admin platform_admin vendor)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :display_name, :string
    field :avatar_url, :string
    field :phone, :string
    field :role, :string, default: "donor"
    field :confirmed_at, :utc_datetime
    field :authenticated_at, :utc_datetime, virtual: true

    belongs_to :agency, TheBridge.Agencies.Agency

    timestamps(type: :utc_datetime)
  end

  def roles, do: @roles

  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :password, :display_name])
    |> validate_email(opts)
    |> validate_password(opts)
    |> validate_required([:display_name])
    |> validate_length(:display_name, min: 2, max: 50)
  end

  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
  end

  defp validate_email(changeset, opts) do
    changeset =
      changeset
      |> validate_required([:email])
      |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/,
        message: "must have the @ sign and no spaces"
      )
      |> validate_length(:email, max: 160)

    if Keyword.get(opts, :validate_unique, true) do
      changeset
      |> unsafe_validate_unique(:email, TheBridge.Repo)
      |> unique_constraint(:email)
      |> validate_email_changed()
    else
      changeset
    end
  end

  defp validate_email_changed(changeset) do
    if get_field(changeset, :email) && get_change(changeset, :email) == nil do
      add_error(changeset, :email, "did not change")
    else
      changeset
    end
  end

  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  def profile_changeset(user, attrs) do
    user
    |> cast(attrs, [:display_name, :avatar_url, :phone])
    |> validate_length(:display_name, min: 2, max: 50)
  end

  def role_changeset(user, attrs) do
    user
    |> cast(attrs, [:role, :agency_id])
    |> validate_inclusion(:role, @roles)
  end

  def confirm_changeset(user) do
    now = DateTime.utc_now(:second)
    change(user, confirmed_at: now)
  end

  def valid_password?(%TheBridge.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end
end
