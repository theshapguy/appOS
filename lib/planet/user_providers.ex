defmodule Planet.UserProviders do
  @moduledoc """
  The UserProviders context.
  """

  import Ecto.Query, warn: false

  alias Planet.Utils
  alias Planet.Accounts.User
  alias Planet.Repo
  alias Planet.UserProviders.UserProvider

  @doc """
  Retrieves a user provider record by user ID and provider.

  This function fetches a user provider record from the database based on the
  given `user_id` and `provider`.

  ## Parameters

    - `user_id`: The ID of the user.
    - `provider`: The name of the provider.

  ## Examples

      iex> get_provider_by_user_and_provider(1, "google")
      %UserProvider{}

      iex> get_provider_by_user_and_provider(1, "nonexistent")
      nil

  """
  def get_provider_by_user_and_provider(user_id, provider) do
    Repo.get_by(UserProvider, user_id: user_id, provider: provider)
  end

  @doc """
  Upserts a user provider record in the database.

  This function inserts a new user provider record or updates the existing one
  if a conflict is detected based on the `user_id` and `provider` fields.

  ## Parameters

    - `user`: A `%User{}` struct representing the user.
    - `ueberauth_auth`: A `%Ueberauth.Auth{}` struct containing the authentication data.

  ## Examples

      iex> upsert_provider(user, ueberauth_auth)
      {:ok, %UserProvider{}}

  """
  def upsert_provider(%User{} = user, %Ueberauth.Auth{} = ueberauth_auth) do
    provider_data = %{
      user_id: user.id,
      provider: Atom.to_string(ueberauth_auth.provider),
      object: Utils.convert(ueberauth_auth.extra.raw_info),
      token: ueberauth_auth.credentials.token
    }

    Repo.insert(
      %UserProvider{} |> UserProvider.changeset(provider_data),
      on_conflict: [
        set: [
          object: provider_data.object,
          token: provider_data.token
        ]
      ],
      conflict_target: [:user_id, :provider]
    )
  end

  @doc """
  Creates a user_provider.

  ## Examples

      iex> create_user_provider(%{field: value})
      {:ok, %UserProvider{}}

      iex> create_user_provider(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_provider(attrs \\ %{}) do
    %UserProvider{}
    |> UserProvider.changeset(attrs)
    |> Repo.insert()
  end
end
