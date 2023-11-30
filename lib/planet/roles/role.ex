defmodule Planet.Roles.Role do
  use Planet.Schema
  import Ecto.Changeset
  alias Planet.ChangesetHelpers
  alias Planet.Roles.Permissions

  schema "roles" do
    field :name, :string
    field :permissions, {:array, :string}, default: []

    field :active, :boolean
    field :editable?, :boolean, source: :is_editable

    belongs_to(:organization, Planet.Organizations.Organization)

    # No Need To Access Users From Roles
    # many_to_many :users, Planet.Accounts.User, join_through: Planet.Accounts.UserRole
    timestamps()
  end

  @doc """
  Query to find all roles for specific organization.
  """
  def query_for_id(
        query \\ __MODULE__,
        id
      ) do
    query
    |> where([u], u.id == ^id)
  end

  @doc """
  Query to find all roles for editable.
  """
  def query_for_editable(
        query \\ __MODULE__,
        editable?
      ) do
    query
    |> where([u], u.editable? == ^editable?)
  end

  @doc """
  Query to find all roles for specific organization.
  """
  def query_for_organization(
        query \\ __MODULE__,
        %Planet.Organizations.Organization{} = organization
      ) do
    query
    |> where([u], u.organization_id == ^organization.id)
  end

  @doc """
  Query to find all roles for specific organization.
  """
  def order_by_editable_and_name(query \\ __MODULE__) do
    query
    # |> order_by([r], asc: :name)
    |> order_by([r], asc: :editable?, asc: :name)
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :permissions, :active])
    |> validate_required([:name, :permissions])
    |> ChangesetHelpers.clean_and_validate_array(
      :permissions,
      Permissions.simple_slug_list()
    )
    |> unique_constraint(:name)

    # |> foreign_key_constraint(
    #   name: :users_roles_role_id_fkey,
    #   message: "Cannot Delete Role While It Is Still Being Used"
    # )
  end

  @doc false
  def registration_changeset(role, attrs) do
    # This method is used while registration takes place so that editable can be set to false
    role
    |> cast(attrs, [:name, :permissions, :active, :editable?])
    # Make Sure It Is Not Editable So That It Cannot Be Deleted
    |> put_change(:editable?, false)
    |> validate_required([:name, :permissions])
    |> ChangesetHelpers.clean_and_validate_array(
      :permissions,
      Permissions.simple_slug_list()
    )
    |> unique_constraint(:name)

    # |> foreign_key_constraint(
    #   name: :users_roles_role_id_fkey,
    #   message: "Cannot Delete Role While It Is Still Being Used"
    # )
  end
end
