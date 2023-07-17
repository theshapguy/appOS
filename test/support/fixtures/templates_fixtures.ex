defmodule AppOS.TemplatesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AppOS.Templates` context.
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
      |> AppOS.Templates.create_template()

    template
  end
end
