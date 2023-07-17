defmodule AppOS.Repo.Migrations.CreateTemplates do
  use Ecto.Migration

  def change do
    create table(:templates) do
      add :name, :string
      add :age, :integer

      timestamps()
    end
  end
end
