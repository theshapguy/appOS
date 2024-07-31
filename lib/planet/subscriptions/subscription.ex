defmodule Planet.Subscriptions.Subscription do
  use Planet.Schema
  import Ecto.Changeset

  @status_values [
    # Paddle
    :active,
    :trialing,
    :past_due,
    :free,
    :paused,
    :deleted,

    # Custom
    # used when paddle webhook does not verify within 20 seconds
    # or some other error, we can bypass it with forced_active and know which once are manually
    # activated accounts
    # Removed, use processor to detect which webhook handler has affected this
    # :forced_active,
    # Initial Condition
    :unpaid
  ]

  @processor_values [
    # classic paddle
    :paddle,
    :"paddle-billing",
    :stripe,
    # When things get manual
    :manual
  ]

  @primary_key false
  # @primary_key {:organization_id, :id, []}
  @derive {Jason.Encoder,
           only: [
             :product_id,
             :customer_id,
             :status,
             :issued_at,
             :valid_until
           ]}
  schema "subscriptions" do
    belongs_to(:organization, Planet.Organizations.Organization, primary_key: true)

    field(:product_id, :string)

    field(:customer_id, :string)
    field(:subscription_id, :string)

    field(:status, Ecto.Enum, values: @status_values)

    field(:issued_at, :utc_datetime)
    field(:valid_until, :utc_datetime)

    field(:payment_attempt, :string)

    field(:update_url, :string)
    field(:cancel_url, :string)

    field(:processor, Ecto.Enum, values: @processor_values)

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

  @doc """
  Query to find all roles for specific organization.
  """
  def query_by_id(query \\ __MODULE__, id) do
    query
    |> where([s], s.organization_id == ^id)
  end

  def query_by_status(query \\ __MODULE__, status) do
    query
    |> where([s], s.status == ^status)
  end

  def query_for_lock(query \\ __MODULE__) do
    query
    |> lock("FOR UPDATE")
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [
      :product_id,
      :customer_id,
      :subscription_id,
      :status,
      :issued_at,
      :valid_until,
      :payment_attempt,
      :update_url,
      :cancel_url,
      :processor
      # :paddle
    ])
    |> validate_required([
      :product_id,
      :status,
      :issued_at,
      :valid_until
    ])
    |> maybe_put_assoc(:organization, attrs)
    |> unique_constraint(:organization, name: :subscriptions_pkey)
  end
end
