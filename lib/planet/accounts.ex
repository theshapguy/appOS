defmodule Planet.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Planet.Utils
  alias Planet.UserProviders.UserProvider
  alias Planet.Repo

  alias Planet.Accounts.{User, UserToken, UserNotifier}

  alias Planet.Organizations
  alias Planet.Organizations.Organization

  alias Planet.Subscriptions
  alias Planet.Subscriptions.Subscription

  alias Planet.Roles
  alias Planet.Roles.Role

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_email(email, :subscription) when is_binary(email) do
    Repo.get_by(User, email: email) |> Repo.preload(organization: [:subscription])
  end

  # def get_user_by_customer_id(payment_processor_customer_id) when is_binary(payment_processor_customer_id) do
  #   User
  #   |> where([u], u.organization_admin? == true)
  #   |> where([u, o, s], s.customer_id == ^payment_processor_customer_id)
  #   |> join(:inner, [u], o in assoc(u, :organization))
  #   |> join(:inner, [u, o], s in assoc(o, :subscription))
  #   |> preload([u, o, s], organization: {o, subscription: s})
  #   |> Repo.one()
  # end

  # def get_user_by_email(email, :subscription) when is_binary(email) do
  #   Repo.get_by(User, email: email) |> Repo.preload(organization: [:subscription])
  # end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id),
    do:
      Repo.get!(User, id)
      |> Repo.preload([{:organization, :subscription}])

  def get_user(id),
    do:
      Repo.get(User, id)
      |> Repo.preload([{:organization, :subscription}])

  def get_user!(%Organization{} = organization, id) do
    User
    |> User.query_for_organization(organization)
    |> User.query_for_id(id)
    |> Repo.one!()
    |> Repo.preload([{:organization, :subscription}])
    |> Repo.preload(:roles)
  end

  # |> Repo.preload([:roles])

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  # def register_user(attrs) do
  #   %User{}
  #   |> User.registration_changeset(attrs)
  #   |> Repo.insert()
  # end

  def register_user(attrs, ueberauth_auth \\ nil) do
    user_changeset =
      %User{organization_admin?: true}
      |> User.registration_changeset(attrs)

    # Extract Refer Code From Virtual Field Invite Code
    # Virtual Field Invite Code Exists In User Schema
    # Using this method rather than sending another function argument
    refer_code = Map.get(attrs, "invite_code", "")

    invited_by_organization_id =
      case Organizations.get_organization_by_refer_code(refer_code) do
        %Organization{id: id} -> id
        _ -> nil
      end

    organization_changeset =
      %Organization{
        invited_by_id: invited_by_organization_id,
        timezone: Map.get(attrs, "timezone", "Etc/UTC")
      }
      # Sending user attrs to cast email
      |> Organizations.change_organization_for_registration(attrs)

    subscription_changeset =
      Subscriptions.change_subscription(
        %Subscription{},
        Planet.Payments.Plans.free_default_plan_as_subscription_attrs()
        # %{
        #   "status" => subscription_status,
        #   "product_id" => "default",
        #   "price_id" => "default",
        #   "issued_at" => DateTime.utc_now(),
        #   # Date Plus 100 years for Free Plan
        #   "valid_until" => DateTime.utc_now() |> DateTime.add(3_153_600_000, :second),
        #   "processor" => "manual"
        # }
      )

    administrator_role_changeset =
      Roles.change_role_registration(
        %Role{},
        %{
          "name" => "Administrator",
          "editable?" => "false",
          "permissions" => [Planet.Roles.Permissions.admin_user_permission()]
        }
      )

    normal_user_changeset =
      Roles.change_role(
        %Role{},
        %{
          "name" => "Simple User",
          "permissions" => Planet.Roles.Permissions.normal_user_default_permission_list()
        }
      )

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:organization, organization_changeset)
    |> Ecto.Multi.run(:subscription, fn repo, %{organization: organization} ->
      subscription_changeset
      |> Ecto.Changeset.put_assoc(:organization, organization)
      |> repo.insert()
    end)
    |> Ecto.Multi.run(:admin_role, fn repo, %{organization: organization} ->
      administrator_role_changeset
      |> Ecto.Changeset.put_assoc(:organization, organization)
      |> repo.insert()
    end)
    |> Ecto.Multi.run(:normal_role, fn repo, %{organization: organization} ->
      normal_user_changeset
      |> Ecto.Changeset.put_assoc(:organization, organization)
      |> repo.insert()
    end)
    |> Ecto.Multi.run(:user, fn repo, %{organization: organization, admin_role: admin_role} ->
      # Use the inserted organization.
      user_changeset
      |> Ecto.Changeset.put_assoc(:organization, organization)
      |> Ecto.Changeset.put_assoc(:roles, [admin_role])
      |> Ecto.Changeset.put_assoc(:user_providers, [])
      |> repo.insert()
    end)
    |> maybe_insert_provider(ueberauth_auth)

    # |> Ecto.Multi.run(:user_providers, fn repo, %{user: user} ->
    #   # convert(social_auth.extra.raw_info)

    #   %UserProvider{}
    #   |> UserProvider.changeset(%{
    #     "token" => social_auth.credentials.token,
    #     "provider" => Atom.to_string(social_auth.provider),
    #     "object" => Utils.convert(social_auth.extra.raw_info)
    #   })
    #   |> Ecto.Changeset.put_assoc(:user, user)
    #   |> repo.insert()
    # end)

    # |> maybe_add_user_credential_changeset(user_credential_attrs)

    # If Web AuthN, Add Transaction To Add User Credentials, If Not Ignore This Step

    |> Repo.transaction()
    |> case do
      # Need to preload organization because it is required
      {:ok, %{user: user}} ->
        {
          :ok,
          user
          |> Repo.preload([{:organization, :subscription}])
        }

      {:error, :user, changeset, _} ->
        {:error, changeset}

      {:error, :organization, changeset, _} ->
        {:error, changeset}

      {:error, :subscription, changeset, _} ->
        {:error, changeset}
    end
  end

  def register_user!(attrs) do
    case register_user(attrs) do
      {:ok, user} ->
        user

      {:error, changeset} ->
        raise changeset
        # raise Ecto.InvalidChangesetError,
        #   action: :insert,
        #   changeset: changeset
    end
  end

  def maybe_insert_provider(multi, %Ueberauth.Auth{} = social_auth) do
    multi
    |> Ecto.Multi.run(:user_providers, fn repo, %{user: user} ->
      %UserProvider{}
      |> UserProvider.changeset(%{
        "token" => social_auth.credentials.token,
        "provider" => Atom.to_string(social_auth.provider),
        "object" => Utils.convert(social_auth.extra.raw_info)
      })
      |> Ecto.Changeset.put_assoc(:user, user)
      |> repo.insert()
    end)
  end

  def maybe_insert_provider(multi, nil) do
    multi
  end

  # def convert(map) when is_map(map) do
  #   Map.new(map, fn {k, v} -> {k, v} end)
  # end

  # def convert(struct) when is_struct(struct) do
  #   struct
  #   |> Map.from_struct()
  #   |> convert()
  # end

  # def convert(value), do: value

  # Not Used For Now
  # defp maybe_add_user_credential_changeset(
  #        %Ecto.Multi{} = multi,
  #        %{
  #          "attestationObject" => attestation_object_b64,
  #          "clientDataJSON" => client_data_json,
  #          "rawID" => raw_id_b64,
  #          "type" => "public-key",
  #          "deviceName" => device_name
  #        } = user_credential_attrs
  #      )
  #      when is_map(user_credential_attrs) do
  #   # {:ok, {authenticator_data, _result}} =
  #   #   Wax.register(
  #   #     attestation_object,
  #   #     client_data_json,
  #   #     challenge
  #   #   )

  #   # If User Credential Not Nil, Add Ecto Multi
  #   Ecto.Multi.run(multi, :user_credential, fn repo, %{user: user} ->
  #     UserCredentials.change_user_credentail(%UserCredentail{}, user_credential_attrs)
  #     |> Ecto.Changeset.put_assoc(:user, user)
  #     |> repo.insert()
  #   end)
  # end

  # defp maybe_add_user_credential_changeset(%Ecto.Multi{} = multi, nil) do
  #   # If User Credential Is Nil, Continue
  #   multi
  # end

  def register_user_with_organization(%Organization{} = organization, %Role{} = role, attrs) do
    %User{}
    |> User.registration_changeset_organization_member(attrs)
    |> Ecto.Changeset.put_assoc(:organization, organization)
    |> Ecto.Changeset.put_assoc(:roles, [role])
    |> Repo.insert()
  end

  @doc ~S"""
  Delivers the organization invite email instructions to the given user.

  ## Examples

      iex> deliver_user_invite_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_invite_instructions(%User{} = member, %User{} = owner, invite_url_fun)
      when is_function(invite_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(member, "invite")

    Repo.insert!(user_token)

    UserNotifier.deliver_invite_instructions(member, owner, invite_url_fun.(encoded_token))
  end

  @doc """
  Verify a user by the given token for organization invite.

  If the token matches, the user account is marked as verified
  and the user is returned
  """

  def verify_organization_invite_user_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "invite"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  def change_user_registration_with_organization(%User{} = user, attrs \\ %{}) do
    User.registration_changeset_organization_member(user, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user name.

  ## Examples

      iex> change_user_name(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_fullname(user, attrs \\ %{}) do
    User.name_changeset(user, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user timezone.

  ## Examples

      iex> change_user_name(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_timezone(user, attrs \\ %{}) do
    User.timezone_changeset(user, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user name
  """
  def update_user_fullname(%User{} = user, attrs) do
    user
    |> User.name_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates the user timezone
  """
  def update_user_timezone(%User{} = user, attrs) do
    user
    |> User.timezone_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates the user name
  """
  def update_user_organization_admin(%User{} = user, attrs) do
    user
    |> User.organization_admin_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  def update_user_password(user, attrs) when is_map(attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)

    Repo.one(query)
    |> Repo.preload([{:organization, :subscription}])
    |> Repo.preload(:roles)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  List All Team Members That Are Team Admins For A Specific Organization.

  ## Examples

      iex> list_organization_admin(%Organization{})
      [%User{}]

  """
  def list_organization_members(%Organization{} = organization) do
    User
    |> User.query_for_organization(organization)
    |> User.query_sort_by_admins_and_name()
    |> Repo.all()
    |> Repo.preload(:roles)
  end

  def list_organization_admins(%Organization{} = organization, opts \\ []) do
    count? = Keyword.get(opts, :count?, false)

    query =
      User
      |> User.query_for_organization(organization)
      |> User.query_organization_admin?(true)

    # |> User.query_sort_by_admins_and_name()
    # |> Repo.all()
    # |> Repo.aggregate(:count, :id)

    case count? do
      true ->
        query
        |> Repo.aggregate(:count, :id)

      false ->
        query |> Repo.all()
    end
  end
end
