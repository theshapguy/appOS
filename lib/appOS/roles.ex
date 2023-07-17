defmodule AppOS.Roles do
  @moduledoc """
  The Roles context.
  """

  import Ecto.Query, warn: false
  alias AppOS.Repo

  alias AppOS.Roles.Role
  alias AppOS.Organizations.Organization

  @doc """
  Returns the list of roles for a specific organization

  ## Examples

      iex> list_roles(%Organization{} = organization)
      [%Role{}, ...]

  """
  def list_roles(%Organization{} = organization) do
    Role
    |> Role.query_for_organization(organization)
    |> Role.order_by_editable_and_name()
    |> Repo.all()
  end

  def list_roles() do
    Role
    |> Role.order_by_editable_and_name()
    |> Repo.all()
  end

  @doc """
  Gets a single role.

  Raises `Ecto.NoResultsError` if the Role does not exist.

  ## Examples

      iex> get_role!(123)
      %Role{}

      iex> get_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_role!(%Organization{} = organization, id, opts \\ []) do
    Role
    |> Role.query_for_organization(organization)
    |> Role.query_for_id(id)
    # Make Sure Role Is Editable So That User Can Go to Edit/Delete/Update Page
    |> maybe_ignore_editable(opts)
    |> Repo.one!()
  end

  def maybe_ignore_editable(query, opts \\ []) do
    ignore_editable = Keyword.get(opts, :ignore_editable, false)

    case ignore_editable do
      true ->
        # Dont Add Query to Filter Editable
        query

      false ->
        # Add Query to Filter Editable
        query
        |> Role.query_for_editable(true)
    end
  end

  @doc """
  Creates a role.

  ## Examples

      iex> create_role(%{field: value})
      {:ok, %Role{}}

      iex> create_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_role(%Organization{} = organization, attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:organization, organization)
    |> Repo.insert()
  end

  @doc """
  Updates a role.

  ## Examples

      iex> update_role(role, %{field: new_value})
      {:ok, %Role{}}

      iex> update_role(role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_role(%Organization{} = _organization, %Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    # |> Ecto.Changeset.put_assoc(:organization, organization)
    |> Repo.update()
  end

  @doc """
  Deletes a role.

  ## Examples

      iex> delete_role(role)
      {:ok, %Role{}}

      iex> delete_role(role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_role(%Role{} = role) do
    role
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.foreign_key_constraint(:name,
      name: :users_roles_role_id_fkey,
      message:
        "This role is still associated to an user. Remove all users from this role to delete."
    )
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking role changes.

  ## Examples

      iex> change_role(role)
      %Ecto.Changeset{data: %Role{}}

  """
  def change_role(%Role{} = role, attrs \\ %{}) do
    Role.changeset(role, attrs)
  end

  def change_role_registration(%Role{} = role, attrs \\ %{}) do
    Role.registration_changeset(role, attrs)
  end
end
