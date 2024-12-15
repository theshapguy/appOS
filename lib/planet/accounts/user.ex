defmodule Planet.Accounts.User do
  use Planet.Schema
  import Ecto.Changeset

  schema "users" do
    field(:email, :string)
    field(:password, :string, virtual: true, redact: true)
    field(:hashed_password, :string, redact: true)
    field(:current_password, :string, virtual: true, redact: true)
    field(:confirmed_at, :naive_datetime)

    field(:name, :string)

    field(:superuser?, :boolean, default: false, source: :is_superuser)
    field(:organization_admin?, :boolean, default: false, source: :is_organization_admin)

    field(:active?, :boolean, default: true, source: :is_active)

    belongs_to(:organization, Planet.Organizations.Organization)

    has_many(:user_credentials, Planet.UserCredentials.UserCredentail)
    has_many(:user_providers, Planet.UserProviders.UserProvider)

    # Use To Send the Refer Code Of Organization In User Attrs
    # So that Data can be extracted
    field(:refer_code, :string, virtual: true)

    many_to_many :roles, Planet.Roles.Role,
      join_through: Planet.Accounts.UserRole,
      on_replace: :delete

    field(:timezone, :string)

    timestamps()
  end

  @doc """
  Query to find user by id.
  """
  def query_for_id(query \\ __MODULE__, id) do
    query
    |> where([u], u.id == ^id)
  end

  @doc """
  Query to find all users for specific team.
  """
  def query_for_organization(
        query \\ __MODULE__,
        %Planet.Organizations.Organization{} = organization
      ) do
    query
    |> where([u], u.organization_id == ^organization.id)
  end

  @doc """
  Query to find organization_admin?.
  """
  def query_organization_admin?(query \\ __MODULE__, organization_admin?) do
    query
    |> where([u], u.organization_admin? == ^organization_admin?)
    |> order_by(asc: :name)

    # from u in query,
    # where: u.team_id == ^team.id
  end

  @doc """
  Query To Sort By Name
  """
  def query_sort_by_admins_and_name(query \\ __MODULE__) do
    query
    |> order_by(desc: :organization_admin?, asc: :name)
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :password, :name, :refer_code, :organization_admin?])
    |> put_change_name_as_email()
    |> validate_length(:name, max: 240)
    |> validate_email(opts)
    |> validate_password(opts)
  end

  def registration_changeset_organization_member(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:name, :email, :password, :organization_id])
    |> put_change_name_as_email()
    |> validate_length(:name, max: 240)
    |> validate_email(opts)
    |> generate_random_password()
    |> validate_password(opts)
  end

  def put_change_name_as_email(changeset) do
    if changeset.valid? do
      email = changeset |> get_field(:email)
      changeset |> put_change(:name, email)
    else
      changeset
    end
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    # Examples of additional password validation:
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, Planet.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the name.

  It requires the name to change otherwise an error is added.
  """
  def name_changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, max: 255)
    |> case do
      %{changes: %{name: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :name, "did not change")
    end
  end

  @doc """
  A timezone changeset for changing the timezone

  It requires the name to change otherwise an error is added.
  """
  def timezone_changeset(user, attrs) do
    user
    |> cast(attrs, [:timezone])
    |> validate_required([:timezone])
    |> validate_length(:name, max: 255)
    |> case do
      %{changes: %{timezone: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :timezone, "did not change")
    end
    |> validate_timezone()
  end

  def validate_timezone(changeset) do
    timezone = changeset |> get_field(:timezone)

    case Tzdata.zone_exists?(timezone) do
      false -> changeset |> add_error(:timezone, "timezone does not exist")
      true -> changeset
    end
  end

  @doc """
  A user changeset for changing the name.

  It requires the name to change otherwise an error is added.
  """
  def organization_admin_changeset(user, attrs) do
    user
    |> cast(attrs, [:organization_admin?])
    |> validate_required([:organization_admin?])
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Planet.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    changeset = cast(changeset, %{current_password: password}, [:current_password])

    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end

  defp generate_random_password(changeset) do
    if changeset.valid? do
      changeset
      |> put_change(:password, random_string(50))
    else
      changeset
    end
  end
end
