defmodule AppOS.UserCredentials do
  @moduledoc """
  The UserCredentials context.
  """

  import Ecto.Query, warn: false
  alias AppOS.Repo

  alias AppOS.UserCredentials.UserCredentail
  alias AppOS.Accounts.User

  @doc """
  Returns the list of user_credentials.

  ## Examples

      iex> list_user_credentials()
      [%UserCredentail{}, ...]

  """
  def list_user_credentials(%User{} = user) do
    UserCredentail
    |> UserCredentail.query_for_user(user)
    |> Repo.all()
  end

  @doc """
  List of user_credentails for a specific user.

  If wax_authenticate_credentials is true -> map ecto results to setup for Wax.authenticate()

  ## Examples

      iex> get_user_credentails!(123, true)
      [{}, {}]

      iex> get_user_credentails!(123, false)
      [%UserCredentail{}]

      iex> get_user_credentails!(456)
      ** []

  """

  def get_user_credentails!(user_id_base32) do
    UserCredentail
    |> UserCredentail.query_for_user_id(user_id_base32)
    |> Repo.all()
  end

  def get_user_credentails!(user_id_base32, :for_wax_credentials) do
    get_user_credentails!(user_id_base32)
    |> Enum.map(fn uc -> {uc.credential_id, uc.credential_public_key} end)
  end

  def get_user_credentails!(user_id_base32, :for_wax_aaguid) do
    get_user_credentails!(user_id_base32)
    |> Enum.map(fn uc -> {uc.credential_id, uc.aaguid} end)
    |> Enum.into(%{})
  end

  @doc """
  Creates a user_credentail.

  ## Examples

      iex> create_user_credentail(%{field: value})
      {:ok, %UserCredentail{}}

      iex> create_user_credentail(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_credentail(%User{} = user, attrs \\ %{}) do
    %UserCredentail{}
    |> UserCredentail.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a user_credentail.

  ## Examples

      iex> update_user_credentail(user_credentail, %{field: new_value})
      {:ok, %UserCredentail{}}

      iex> update_user_credentail(user_credentail, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_credentail(%UserCredentail{} = user_credentail, attrs) do
    user_credentail
    |> UserCredentail.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_credentail.

  ## Examples

      iex> delete_user_credentail(user_credentail)
      {:ok, %UserCredentail{}}

      iex> delete_user_credentail(user_credentail)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_credentail(%User{} = user, user_credentail_id) do
    UserCredentail
    |> UserCredentail.query_for_user(user)
    |> UserCredentail.query_for_id(user_credentail_id)
    |> Repo.one()
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_credentail changes.

  ## Examples

      iex> change_user_credentail(user_credentail)
      %Ecto.Changeset{data: %UserCredentail{}}

  """
  def change_user_credentail(%UserCredentail{} = user_credentail, attrs \\ %{}) do
    UserCredentail.changeset(user_credentail, attrs)
  end
end
