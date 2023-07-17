defmodule AppOS.UserCredentials.UserCredentail do
  use AppOS.Schema

  alias AppOS.EctoType.CoseKey
  import Ecto.Changeset

  schema "user_credentials" do
    field :credential_id, :string
    field :credential_public_key, CoseKey
    field :aaguid, :binary
    field :nickname, :string
    belongs_to(:user, AppOS.Accounts.User)

    timestamps()
  end

  @doc """
  Query to find all credetials for specific user.
  """
  def query_for_id(query \\ __MODULE__, id) do
    query
    |> where([u], u.id == ^id)
  end

  @doc """
  Query to find all credetials for specific user.
  """
  def query_for_user_id(query \\ __MODULE__, user_id_base32) do
    query
    |> where([u], u.user_id == ^user_id_base32)
  end

  @doc """
  Query to find all credetials for specific user.
  """
  def query_for_user(query \\ __MODULE__, %AppOS.Accounts.User{} = user) do
    query
    |> where([u], u.user_id == ^user.id)
  end

  @doc false
  def changeset(user_credentail, attrs) do
    user_credentail
    |> cast(attrs, [:credential_id, :credential_public_key, :aaguid, :nickname])
    |> validate_required([:credential_id, :credential_public_key, :nickname])
    |> unique_constraint(:credential_id)

    # |> maybe_put_assoc(:user, attrs)
    # |> unique_constraint(:user, name: :user_credentials_user_id_index)
  end
end

# * creating lib/appOS/user_credentials/user_credentail.ex
# * creating priv/repo/migrations/20230714085951_create_user_credentials.exs
# * creating lib/appOS/user_credentials.ex
# * injecting lib/appOS/user_credentials.ex
# * creating test/appOS/user_credentials_test.exs
# * injecting test/appOS/user_credentials_test.exs
# * creating test/support/fixtures/user_credentials_fixtures.ex
# * injecting test/support/fixtures/user_credentials_fixtures.ex
