defmodule Planet.UserProvidersTest do
  use Planet.DataCase

  alias Planet.UserProviders
  import Planet.AccountsFixtures
  import Planet.UserProvidersFixtures

  describe "user_providers" do
    alias Planet.UserProviders.UserProvider

    setup do
      user = user_fixture()

      user_provider =
        user |> user_provider_fixture(%{provider: "test_provider", token: "__some_token__"})

      %{user: user, user_provider: user_provider}
    end

    test "returns the user provider when it exists", %{user: user, user_provider: user_provider} do
      result =
        Planet.UserProviders.get_provider_by_user_and_provider(
          user.id,
          user_provider.provider
        )

      assert result == user_provider
    end

    test "returns nil when the user provider does not exist", %{user: user} do
      result = Planet.UserProviders.get_provider_by_user_and_provider(user.id, "nonexistent")
      assert result == nil
    end

    test "create_user_provider/1 with valid data creates a user_provider", %{user: user} do
      valid_attrs = %{
        token: "some token",
        provider: "some provider",
        object: %{},
        user_id: user.id
      }

      assert {:ok, %UserProvider{} = user_provider} =
               UserProviders.create_user_provider(valid_attrs)

      assert user_provider.token == "some token"
      assert user_provider.provider == "some provider"
      assert user_provider.object == %{}
      assert user_provider.user_id == user.id
    end

    test "inserts a new user provider", %{user: user} do
      ueberauth_auth = %Ueberauth.Auth{
        provider: :google,
        credentials: %{token: "token"},
        extra: %{raw_info: %{}}
      }

      assert {:ok, %UserProvider{}} = UserProviders.upsert_provider(user, ueberauth_auth)

      assert %UserProvider{user_id: _user_id, provider: _provider} =
               Repo.get_by(UserProvider, user_id: user.id, provider: "google")
    end

    test "updates an existing user provider", %{user: user} do
      ueberauth_auth = %Ueberauth.Auth{
        provider: :google,
        credentials: %{token: "new_token"},
        extra: %{raw_info: %{}}
      }

      user_provider = %UserProvider{user_id: user.id, provider: "google", token: "old_token"}
      Repo.insert!(user_provider)

      assert {:ok, %UserProvider{}} = UserProviders.upsert_provider(user, ueberauth_auth)
      updated_provider = Repo.get_by(UserProvider, user_id: user.id, provider: "google")
      assert updated_provider.token == "new_token"
    end

    test "ensures unique UserProvider constraint", %{user: user} do
      assert {:ok, %UserProvider{}} =
               %{"user_id" => user.id, "provider" => "google", "token" => "old_token"}
               |> UserProviders.create_user_provider()

      assert {:error, %Ecto.Changeset{}} =
               %{"user_id" => user.id, "provider" => "google", "token" => "old_token"}
               |> UserProviders.create_user_provider()
    end
  end
end
