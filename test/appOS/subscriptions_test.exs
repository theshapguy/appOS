defmodule AppOS.SubscriptionsTest do
  use AppOS.DataCase

  import AppOS.AccountsFixtures
  import AppOS.SubscriptionsFixtures

  alias AppOS.Subscriptions
  alias AppOS.Subscriptions.Subscription

  describe "subscriptions" do
    setup do
      %{user: user_fixture()}
    end

    @invalid_attrs %{
      product_id: nil,
      customer_id: nil,
      subscription_id: nil,
      subscription_status: nil,
      issued_at: nil,
      valid_until: nil,
      payment_attempt: nil,
      update_url: nil,
      cancel_url: nil
    }

    test "list_subscriptions/0 returns all subscriptions", %{user: user} do
      subscription = subscription_fixture(user)
      subscription2 = subscription_fixture(user_fixture())
      assert Subscriptions.list_subscriptions() == [subscription, subscription2]
    end

    test "get_subscription!/1 returns the subscription with given id", %{user: user} do
      subscription = subscription_fixture(user)
      assert Subscriptions.get_subscription!(subscription.organization_id) == subscription
    end

    test "create_subscription/1 with valid data does not create subscription as user already has subscription attached on user creation" do
      valid_attrs = %{
        product_id: "product_id",
        customer_id: "customer_id",
        subscription_id: "subscription_id",
        subscription_status: "active",
        issued_at: ~U[2023-06-27 13:59:00Z],
        valid_until: ~U[2023-07-27 13:59:00Z],
        payment_attempt: "payment attempt",
        update_url: "some update url",
        cancel_url: "some cancel url"
      }

      user = user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Subscriptions.create_subscription(user.organization, valid_attrs)
    end

    test "create_subscription/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} =
               Subscriptions.create_subscription(user.organization, @invalid_attrs)
    end

    test "update_subscription/2 with valid data updates the subscription", %{user: user} do
      subscription = subscription_fixture(user)

      update_attrs = %{
        product_id: "updated_product_id",
        customer_id: "updated_customer_id",
        subscription_id: "updated_subscription_id",
        subscription_status: :free,
        issued_at: ~U[2023-06-28 13:59:00Z],
        valid_until: ~U[2023-07-30 13:59:00Z],
        payment_attempt: "updated payment attempt",
        update_url: "some update url updated",
        cancel_url: "some cancel url updated"
      }

      assert {:ok, %Subscription{} = subscription} =
               Subscriptions.update_subscription(subscription, update_attrs)

      assert subscription.product_id == "updated_product_id"
      assert subscription.customer_id == "updated_customer_id"
      assert subscription.subscription_id == "updated_subscription_id"
      assert subscription.subscription_status == :free
      assert subscription.issued_at == ~U[2023-06-28 13:59:00Z]
      assert subscription.valid_until == ~U[2023-07-30 13:59:00Z]
      assert subscription.payment_attempt == "updated payment attempt"
      assert subscription.update_url == "some update url updated"
      assert subscription.cancel_url == "some cancel url updated"
    end

    test "update_subscription/2 with invalid data returns error changeset", %{user: user} do
      subscription = subscription_fixture(user)

      assert {:error, %Ecto.Changeset{}} =
               Subscriptions.update_subscription(subscription, @invalid_attrs)

      assert subscription == Subscriptions.get_subscription!(subscription.organization_id)
    end

    test "delete_subscription/1 deletes the subscription", %{user: user} do
      subscription = subscription_fixture(user)
      assert {:ok, %Subscription{}} = Subscriptions.delete_subscription(subscription)

      assert_raise Ecto.NoResultsError, fn ->
        Subscriptions.get_subscription!(subscription.organization_id)
      end
    end

    test "change_subscription/1 returns a subscription changeset", %{user: user} do
      subscription = subscription_fixture(user)
      assert %Ecto.Changeset{} = Subscriptions.change_subscription(subscription)
    end
  end
end
