defmodule Planet.Repo.Migrations.CreateDummies do
  use Ecto.Migration

  def change do
    create table(:dummies) do
      add :name, :string
      add :age, :integer

      timestamps()
    end
  end
end
