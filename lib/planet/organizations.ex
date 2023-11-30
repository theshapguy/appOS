defmodule Planet.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias Planet.Repo

  alias Planet.Organizations.Organization

  @doc """
  Gets a single organization.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization!(123)
      %Organization{}

      iex> get_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_organization!(id), do: Repo.get!(Organization, id) |> Repo.preload(:subscription)

  @doc """
  Gets a single organization by refer code

  returns nil if the Organization does not exist.

  ## Examples

      iex> get_organization_by_refer_code(123)
      %Organization{}

      iex> get_organization_by_refer_code("")
      nil

      iex> get_organization_by_refer_code(nil)
      nil

  """
  def get_organization_by_refer_code(""), do: nil

  def get_organization_by_refer_code(refer_code),
    do:
      Repo.get_by(Organization, refer_code: refer_code)
      |> Repo.preload(:subscription)

  @doc """
  Updates a organization.

  ## Examples

      iex> update_organization(organization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_organization(organization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.

  ## Examples

      iex> change_organization(organization)
      %Ecto.Changeset{data: %Organization{}}

  """
  def change_organization(%Organization{} = organization, attrs \\ %{}) do
    Organization.changeset(organization, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.

  ## Examples

      iex> change_organization_for_registration(organization)
      %Ecto.Changeset{data: %Organization{}}

  """
  def change_organization_for_registration(%Organization{} = organization, attrs \\ %{}) do
    Organization.registration_changeset(organization, attrs)
  end
end
