defmodule Planet.Subscriptions do
  @moduledoc """
  The Subscriptions context.
  """

  import Ecto.Query, warn: false
  alias Planet.Repo

  alias Planet.Subscriptions.Subscription
  alias Planet.Organizations.Organization

  @doc """
  Returns the list of subscriptions.

  ## Examples

      iex> list_subscriptions()
      [%Subscription{}, ...]

  """

  def list_subscriptions do
    Subscription
    |> Subscription.order_by_id()
    |> Repo.all()
  end

  @doc """
  Gets a single subscription.

  Raises `Ecto.NoResultsError` if the Subscription does not exist.

  ## Examples

      iex> get_subscription!(123)
      %Subscription{}

      iex> get_subscription!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription!(id), do: Repo.get!(Subscription, id)

  def get_subscription_by_customer_id(customer_id) when is_binary(customer_id) do
    Repo.get_by(Subscription, customer_id: customer_id)
  end

  @doc """
  Reload a single subscription.
  """
  def reload!(%Subscription{} = subscription), do: Repo.reload(subscription)

  @doc """
  Creates a subscription.

  ## Examples

      iex> create_subscription(%{field: value})
      {:ok, %Subscription{}}

      iex> create_subscription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription(%Organization{} = organization, attrs \\ %{}) do
    # Use This Rather Than Put Assoc; Put Assoc is Inside Subscription
    # This Allows Unique Constraint To Be Used Easily
    attrs = attrs |> Map.put(:organization, organization)

    %Subscription{}
    |> Subscription.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subscription.

  ## Examples

      iex> update_subscription(subscription, %{field: new_value})
      {:ok, %Subscription{}}

      iex> update_subscription(subscription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

      If Subscription Is not Found Return {:ok, :not_found}
      So the The API Response Can return 200

      iex> update_subscription(nil, %{})
      {:error, :not_found}

  """
  def update_subscription(%Subscription{} = subscription, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:subscription, fn repo, _changes ->
      {
        :ok,
        Subscription
        |> Subscription.query_by_id(subscription.organization_id)
        |> Subscription.query_for_lock()
        |> repo.one()
      }

      # query =
      #   from(
      #     s in Subscription,
      #     where: s.organization_id == ^subscription.organization_id,
      #     lock: "FOR UPDATE"
      #   )

      # Since it is update there has to be one item already existing
      # {:ok, repo.one!(query)}
    end)
    |> Ecto.Multi.run(:update_subscription, fn repo, %{subscription: subscription} ->
      subscription
      |> Subscription.changeset(attrs)
      |> repo.update()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{update_subscription: subscription}} -> {:ok, subscription}
      {:error, :update_subscription, changeset, _changes} -> {:error, changeset}
    end
  end

  def update_subscription(nil, attrs) when is_map(attrs) do
    {:ok, :not_found}
  end

  def maybe_force_active(%{"timestamp" => timestamp, "organization_id" => id}) do
    # Add 1 hour to timestamp (3600s)
    timestamp_plus_1hr = Timex.from_unix(String.to_integer(timestamp) + 3600, :seconds)

    Repo.transaction(fn ->
      Subscription
      |> Subscription.query_by_id(id)
      |> Subscription.query_by_status(:unpaid)
      |> Subscription.query_for_lock()
      |> Repo.one()
      |> case do
        nil ->
          # Unpaid Subsriber Not Found, Probably Already Updated Via Webhook
          {:ok, :subscriber_not_found}

        %Subscription{} = subscription ->
          subscription
          |> Subscription.changeset(%{
            status: :active,
            valid_until: timestamp_plus_1hr,
            processor: :manual
          })
          |> Repo.update!()
      end
    end)
  end

  @doc """
  Deletes a subscription.

  ## Examples

      iex> delete_subscription(subscription)
      {:ok, %Subscription{}}

      iex> delete_subscription(subscription)
      {:error, %Ecto.Changeset{}}

  """

  def delete_subscription(%Subscription{} = subscription) do
    Repo.delete(subscription)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription changes.

  ## Examples

      iex> change_subscription(subscription)
      %Ecto.Changeset{data: %Subscription{}}

  """
  def change_subscription(%Subscription{} = subscription, attrs \\ %{}) do
    Subscription.changeset(subscription, attrs)
  end
end
