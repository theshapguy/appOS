defmodule Planet.Dummies do
  @moduledoc """
  The Dummies context.
  """

  import Ecto.Query, warn: false
  alias Planet.Repo

  alias Planet.Dummies.Dummy

  @doc """
  Returns the list of dummies.

  ## Examples

      iex> list_dummies()
      [%Dummy{}, ...]

  """
  def list_dummies do
    Repo.all(Dummy)
  end

  @doc """
  Gets a single dummy.

  Raises `Ecto.NoResultsError` if the Dummy does not exist.

  ## Examples

      iex> get_dummy!(123)
      %Dummy{}

      iex> get_dummy!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dummy!(id), do: Repo.get!(Dummy, id)

  @doc """
  Creates a dummy.

  ## Examples

      iex> create_dummy(%{field: value})
      {:ok, %Dummy{}}

      iex> create_dummy(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dummy(attrs \\ %{}) do
    %Dummy{}
    |> Dummy.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dummy.

  ## Examples

      iex> update_dummy(dummy, %{field: new_value})
      {:ok, %Dummy{}}

      iex> update_dummy(dummy, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dummy(%Dummy{} = dummy, attrs) do
    dummy
    |> Dummy.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a dummy.

  ## Examples

      iex> delete_dummy(dummy)
      {:ok, %Dummy{}}

      iex> delete_dummy(dummy)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dummy(%Dummy{} = dummy) do
    Repo.delete(dummy)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dummy changes.

  ## Examples

      iex> change_dummy(dummy)
      %Ecto.Changeset{data: %Dummy{}}

  """
  def change_dummy(%Dummy{} = dummy, attrs \\ %{}) do
    Dummy.changeset(dummy, attrs)
  end
end
