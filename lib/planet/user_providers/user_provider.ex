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
    |> unique_constraint([:user_id, :provider],
      name: :user_providers_user_provider_index,
      message: "user id with provider already exists"
    )
  end
end
