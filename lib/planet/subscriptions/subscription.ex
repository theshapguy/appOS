defmodule Planet.Subscriptions.Subscription do
  use Planet.Schema
  import Ecto.Changeset

  @subscription_status_values [
    # Paddle
    :active,
    :trialing,
    :past_due,
    :free,
    :paused,
    :deleted,
    # Custom
    :forced_active,
    :unpaid
  ]

  @primary_key false
  schema "subscriptions" do
    belongs_to(:organization, Planet.Organizations.Organization, primary_key: true)

    field(:product_id, :string)

    field(:customer_id, :string)
    field(:subscription_id, :string)

    field(:subscription_status, Ecto.Enum, values: @subscription_status_values)

    field(:issued_at, :utc_datetime)
    field(:valid_until, :utc_datetime)

    field(:payment_attempt, :string)

    field(:update_url, :string)
    field(:cancel_url, :string)

    # field(:paddle, {:array, :map}, default: [])

    # Virtual
    field(:title, :string, virtual: true)
    field(:subtitle, :string, virtual: true)
    field(:price, :string, virtual: true)
    field(:level, :integer, virtual: true)

    timestamps()
  end

  @doc """
  Query to find all roles for specific organization.
  """
  def order_by_id(query \\ __MODULE__) do
    query
    |> order_by([s], asc: :organization_id)
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [
      :product_id,
      :customer_id,
      :subscription_id,
      :subscription_status,
      :issued_at,
      :valid_until,
      :payment_attempt,
      :update_url,
      :cancel_url
      # :paddle
    ])
    |> validate_required([
      :product_id,
      :subscription_status,
      :issued_at,
      :valid_until
    ])
    |> maybe_put_assoc(:organization, attrs)
    |> unique_constraint(:organization, name: :subscriptions_pkey)
  end
end
