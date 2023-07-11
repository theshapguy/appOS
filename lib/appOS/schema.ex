defmodule AppOS.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      import Ecto.Query
      # @primary_key {:id, :binary_id, autogenerate: true}
      # @foreign_key_type :binary_id

      # https://github.com/Guildship/guildship/blob/376c2b3b3acf13530084e007dda4247ac692929c/lib/guildship/hashid_ecto_type.ex

      # Using This for HashIDs
      @primary_key {:id, AppOS.HashIdEctoType, read_after_writes: true}
      @foreign_key_type AppOS.HashIdEctoType
      @timestamps_opts [type: :utc_datetime]
    end
  end
end
