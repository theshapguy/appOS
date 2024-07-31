defmodule Planet.UserProvidersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Planet.UserProviders` context.
  """

  @doc """
  Generate a user_provider.
  """
  def user_provider_fixture(attrs \\ %{}) do
    {:ok, user_provider} =
      attrs
      |> Enum.into(%{
        object: %{},
        provider: "some provider",
        token: "some token"
      })
      |> Planet.UserProviders.create_user_provider()

    user_provider
  end
end
