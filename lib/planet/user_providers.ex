defmodule Planet.UserProviders do
  @moduledoc """
  The UserProviders context.
  """

  import Ecto.Query, warn: false

  alias Planet.Utils
  alias Planet.Accounts.User
  alias Planet.Repo
  alias Planet.UserProviders.UserProvider

  def get_provider_by_user_and_provider(user_id, provider) do
    Repo.get_by(UserProvider, user_id: user_id, provider: provider)
  end

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
  Returns the list of user_providers.

  ## Examples

      iex> list_user_providers()
      [%UserProvider{}, ...]

  """
  def list_user_providers do
    Repo.all(UserProvider)
  end

  @doc """
  Gets a single user_provider.

  Raises `Ecto.NoResultsError` if the User provider does not exist.

  ## Examples

      iex> get_user_provider!(123)
      %UserProvider{}

      iex> get_user_provider!(456)
      ** (Ecto.NoResultsError)

  """

  def get_user_provider!(id), do: Repo.get!(UserProvider, id)

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

  @doc """
  Updates a user_provider.

  ## Examples

      iex> update_user_provider(user_provider, %{field: new_value})
      {:ok, %UserProvider{}}

      iex> update_user_provider(user_provider, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_provider(%UserProvider{} = user_provider, attrs) do
    user_provider
    |> UserProvider.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_provider.

  ## Examples

      iex> delete_user_provider(user_provider)
      {:ok, %UserProvider{}}

      iex> delete_user_provider(user_provider)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_provider(%UserProvider{} = user_provider) do
    Repo.delete(user_provider)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_provider changes.

  ## Examples

      iex> change_user_provider(user_provider)
      %Ecto.Changeset{data: %UserProvider{}}

  """
  def change_user_provider(%UserProvider{} = user_provider, attrs \\ %{}) do
    UserProvider.changeset(user_provider, attrs)
  end
end
