defmodule AppOS.UserCredentialsTest do
  use AppOS.DataCase

  alias AppOS.UserCredentials

  describe "user_credentials" do
    alias AppOS.UserCredentials.UserCredentail

    import AppOS.UserCredentialsFixtures

    @invalid_attrs %{
      credential_id: nil,
      credential_public_key: nil,
      credential_public_key_binary: nil
    }

    test "list_user_credentials/0 returns all user_credentials" do
      user_credentail = user_credentail_fixture()
      assert UserCredentials.list_user_credentials() == [user_credentail]
    end

    test "get_user_credentail!/1 returns the user_credentail with given id" do
      user_credentail = user_credentail_fixture()
      assert UserCredentials.get_user_credentail!(user_credentail.id) == user_credentail
    end

    test "create_user_credentail/1 with valid data creates a user_credentail" do
      valid_attrs = %{
        credential_id: "some credential_id",
        credential_public_key: "some credential_public_key",
        credential_public_key_binary: "some credential_public_key_binary"
      }

      assert {:ok, %UserCredentail{} = user_credentail} =
               UserCredentials.create_user_credentail(valid_attrs)

      assert user_credentail.credential_id == "some credential_id"
      assert user_credentail.credential_public_key == "some credential_public_key"
      assert user_credentail.credential_public_key_binary == "some credential_public_key_binary"
    end

    test "create_user_credentail/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserCredentials.create_user_credentail(@invalid_attrs)
    end

    test "update_user_credentail/2 with valid data updates the user_credentail" do
      user_credentail = user_credentail_fixture()

      update_attrs = %{
        credential_id: "some updated credential_id",
        credential_public_key: "some updated credential_public_key",
        credential_public_key_binary: "some updated credential_public_key_binary"
      }

      assert {:ok, %UserCredentail{} = user_credentail} =
               UserCredentials.update_user_credentail(user_credentail, update_attrs)

      assert user_credentail.credential_id == "some updated credential_id"
      assert user_credentail.credential_public_key == "some updated credential_public_key"

      assert user_credentail.credential_public_key_binary ==
               "some updated credential_public_key_binary"
    end

    test "update_user_credentail/2 with invalid data returns error changeset" do
      user_credentail = user_credentail_fixture()

      assert {:error, %Ecto.Changeset{}} =
               UserCredentials.update_user_credentail(user_credentail, @invalid_attrs)

      assert user_credentail == UserCredentials.get_user_credentail!(user_credentail.id)
    end

    test "delete_user_credentail/1 deletes the user_credentail" do
      user_credentail = user_credentail_fixture()
      assert {:ok, %UserCredentail{}} = UserCredentials.delete_user_credentail(user_credentail)

      assert_raise Ecto.NoResultsError, fn ->
        UserCredentials.get_user_credentail!(user_credentail.id)
      end
    end

    test "change_user_credentail/1 returns a user_credentail changeset" do
      user_credentail = user_credentail_fixture()
      assert %Ecto.Changeset{} = UserCredentials.change_user_credentail(user_credentail)
    end
  end
end
