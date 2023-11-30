defmodule Planet.DummiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Planet.Dummies` context.
  """

  @doc """
  Generate a dummy.
  """
  def dummy_fixture(attrs \\ %{}) do
    {:ok, dummy} =
      attrs
      |> Enum.into(%{
        age: 42,
        name: "some name"
      })
      |> Planet.Dummies.create_dummy()

    dummy
  end
end
