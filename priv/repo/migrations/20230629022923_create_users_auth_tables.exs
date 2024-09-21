defmodule Planet.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext", "")

    create table(:organizations) do
      add(:name, :string)
      add(:is_active, :boolean, default: true, null: false)

      add(:domain, :string)
      add(:subdomain, :string)

      add(:invited_by_id, references(:organizations))
      add(:refer_code, :uuid, null: false)

      timestamps()
    end

    create(unique_index(:organizations, [:name]))

    create table(:users) do
      add(:name, :string)

      add(:email, :citext, null: false)
      add(:hashed_password, :string, null: false)
      add(:confirmed_at, :naive_datetime)

      add(:is_superuser, :boolean, null: false, default: false)
      add(:is_organization_admin, :boolean, null: false, default: false)
      add(:is_active, :boolean, null: false, default: true)

      add(:organization_id, references(:organizations, on_delete: :delete_all))
      add(:timezone, :string, default: "UTC", null: false)

      # If Oauth, Provider Is Changed to That User
      # add(:provider, :string, default: "local")

      timestamps()
    end

    create(unique_index(:users, [:email]))

    create table(:users_tokens) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:token, :binary, null: false)
      add(:context, :string, null: false)
      add(:sent_to, :string)
      timestamps(updated_at: false)
    end

    create(index(:users_tokens, [:user_id]))
    create(unique_index(:users_tokens, [:context, :token]))

    create table(:subscriptions, primary_key: false) do
      add(:organization_id, references(:organizations, on_delete: :delete_all), primary_key: true)

      add(:product_id, :string, null: false)

      add(:subscription_id, :string)
      add(:status, :string, null: false)

      add(:customer_id, :string)

      add(:issued_at, :utc_datetime, null: false)
      add(:valid_until, :utc_datetime, null: false)

      add(:payment_attempt, :string)
      # add(:cancelled_at, :utc_datetime)

      add(:cancel_url, :string)
      add(:update_url, :string)

      add(:processor, :string, null: false)

      # add(:is_paddle, :boolean, default: false, null: false)
      # add(:paddle, {:array, :map}, default: [], null: false)

      timestamps()
    end

    create(unique_index(:subscriptions, [:organization_id]))

    create table(:roles) do
      add :name, :citext, null: false
      add :permissions, {:array, :string}, default: [], null: false
      add :active, :boolean, default: true, null: false
      add :is_editable, :boolean, default: true, null: false

      add(:organization_id, references(:organizations, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index(:roles, [:name, :organization_id]))

    create table(:user_credentials) do
      add :credential_id, :string, null: false
      add :credential_public_key, :bytea, null: false
      add :aaguid, :bytea
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :nickname, :string, null: false

      timestamps()
    end

    create index(:user_credentials, [:user_id])
    create(unique_index(:user_credentials, [:credential_id]))

    create table(:users_roles, primary_key: false) do
      add(:role_id, references(:roles), null: false)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)

      timestamps()
    end

    create index(:users_roles, [:user_id])
    create index(:users_roles, [:role_id])

    create(unique_index(:users_roles, [:user_id, :role_id]))

    create table(:user_providers) do
      add :provider, :string, null: false
      add :token, :string, null: false
      add :object, :map, default: %{}, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:user_providers, [:user_id, :provider],
             name: :user_providers_user_provider_index
           )
  end
end
