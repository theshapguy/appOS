defmodule Planet.Dummies.Dummy do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dummies" do
    field :name, :string
    field :age, :integer

    timestamps()
  end

  @doc false
  def changeset(dummy, attrs) do
    dummy
    |> cast(attrs, [:name, :age])
    |> validate_required([:name, :age])
  end
end
