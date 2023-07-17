defmodule AppOS.Templates.Template do
  use AppOS.Schema
  import Ecto.Changeset

  schema "templates" do
    field :age, :integer
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(template, attrs) do
    template
    |> cast(attrs, [:name, :age])
    |> validate_required([:name, :age])
  end
end
