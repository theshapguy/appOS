defmodule AppOS.Accounts.UserRole do
  use AppOS.Schema
  import Ecto.Changeset

  # https://hexdocs.pm/ecto/associations.html#updating-all-associated-records-using-internal-data

  @primary_key false
  schema "users_roles" do
    belongs_to :user, AppOS.Accounts.User
    belongs_to :role, AppOS.Roles.Role
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:user_id, :role_id])
    |> Ecto.Changeset.validate_required([:user_id, :role_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:role_id)
  end
end
