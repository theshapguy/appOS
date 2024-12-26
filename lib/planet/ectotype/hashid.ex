defmodule Planet.EctoType.HashId do
  @moduledoc """

  Converts integers to Hashids.

  See http://hashids.org/ for more information.

  From: https://github.com/elixir-ecto/ecto/issues/2840#issuecomment-441426625
  """

  use Ecto.Type
  @hashids Hashids.new(min_len: 6, salt: "GfZxhzXYRsk6Flz9ysXvQFmdUhPMpGl")

  def type, do: :id

  # Left: Validate the hashid is valid on cast
  def cast(term) when is_binary(term), do: {:ok, term}
  def cast(_), do: :error

  def dump(term) when is_binary(term) do
    @hashids
    |> Hashids.decode!(term)
    |> case do
      [int] -> {:ok, int}
      _ -> :error
    end
  end

  def dump(_), do: :error

  def load(term) when is_integer(term), do: {:ok, Hashids.encode(@hashids, term)}
  def load(_), do: :error
end
