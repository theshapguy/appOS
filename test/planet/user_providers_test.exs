defmodule Planet.UserProvidersTest do
  use Planet.DataCase

  alias Planet.UserProviders

  describe "user_providers" do
    alias Planet.UserProviders.UserProvider

    import Planet.UserProvidersFixtures

    @invalid_attrs %{token: nil, provider: nil, object: nil}

    test "list_user_providers/0 returns all user_providers" do
      user_provider = user_provider_fixture()
      assert UserProviders.list_user_providers() == [user_provider]
    end

    test "get_user_provider!/1 returns the user_provider with given id" do
      user_provider = user_provider_fixture()
      assert UserProviders.get_user_provider!(user_provider.id) == user_provider
    end

    test "create_user_provider/1 with valid data creates a user_provider" do
      valid_attrs = %{token: "some token", provider: "some provider", object: %{}}

      assert {:ok, %UserProvider{} = user_provider} = UserProviders.create_user_provider(valid_attrs)
      assert user_provider.token == "some token"
      assert user_provider.provider == "some provider"
      assert user_provider.object == %{}
    end

    test "create_user_provider/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserProviders.create_user_provider(@invalid_attrs)
    end

    test "update_user_provider/2 with valid data updates the user_provider" do
      user_provider = user_provider_fixture()
      update_attrs = %{token: "some updated token", provider: "some updated provider", object: %{}}

      assert {:ok, %UserProvider{} = user_provider} = UserProviders.update_user_provider(user_provider, update_attrs)
      assert user_provider.token == "some updated token"
      assert user_provider.provider == "some updated provider"
      assert user_provider.object == %{}
    end

    test "update_user_provider/2 with invalid data returns error changeset" do
      user_provider = user_provider_fixture()
      assert {:error, %Ecto.Changeset{}} = UserProviders.update_user_provider(user_provider, @invalid_attrs)
      assert user_provider == UserProviders.get_user_provider!(user_provider.id)
    end

    test "delete_user_provider/1 deletes the user_provider" do
      user_provider = user_provider_fixture()
      assert {:ok, %UserProvider{}} = UserProviders.delete_user_provider(user_provider)
      assert_raise Ecto.NoResultsError, fn -> UserProviders.get_user_provider!(user_provider.id) end
    end

    test "change_user_provider/1 returns a user_provider changeset" do
      user_provider = user_provider_fixture()
      assert %Ecto.Changeset{} = UserProviders.change_user_provider(user_provider)
    end
  end
end
