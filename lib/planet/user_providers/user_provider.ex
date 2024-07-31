defmodule Planet.UserProviders.UserProvider do
  alias Planet.Accounts.User
  use Planet.Schema
  import Ecto.Changeset

  schema "user_providers" do
    belongs_to :user, User

    field :token, :string
    field :provider, :string
    field :object, :map

    timestamps()
  end

  @doc false
  def changeset(user_provider, attrs) do
    user_provider
    |> cast(attrs, [:provider, :token, :object, :user_id])
    |> validate_required([:provider, :token])
  end
end
