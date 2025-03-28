defmodule Planet.TemplatesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Planet.Templates` context.
  """

  @doc """
  Generate a template.
  """
  def template_fixture(attrs \\ %{}) do
    {:ok, template} =
      attrs
      |> Enum.into(%{
        age: 42,
        name: "some name"
      })
      |> Planet.Templates.create_template()

    template
  end
end
