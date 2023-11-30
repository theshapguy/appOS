defmodule Planet.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query

      # https://github.com/Guildship/guildship/blob/376c2b3b3acf13530084e007dda4247ac692929c/lib/guildship/hashid_ecto_type.ex

      # Using This for HashIDs
      @primary_key {:id, Planet.EctoType.HashId, autogenerate: true}
      @foreign_key_type Planet.EctoType.HashId
      @timestamps_opts [type: :utc_datetime]

      defp maybe_put_assoc(changeset, assoc, attrs) when assoc in ~w(organization)a do
        if resource = attrs[to_string(assoc)] || attrs[assoc] do
          put_assoc(changeset, assoc, resource)
        else
          changeset
        end
      end
    end
  end
end
