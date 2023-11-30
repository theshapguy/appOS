defmodule Planet.UserCredentialsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Planet.UserCredentials` context.
  """

  @doc """
  Generate a user_credentail.
  """
  def user_credentail_fixture(attrs \\ %{}) do
    {:ok, user_credentail} =
      attrs
      |> Enum.into(%{
        credential_id: "some credential_id",
        credential_public_key: "some credential_public_key",
        credential_public_key_binary: "some credential_public_key_binary"
      })
      |> Planet.UserCredentials.create_user_credentail()

    user_credentail
  end
end
