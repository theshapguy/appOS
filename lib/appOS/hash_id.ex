defmodule AppOS.HashId do
  def hashid do
    salt = "GfZxhzXYRsk6Flz9ysXvQFmdUhPMpGl"
    Hashids.new(salt: salt, min_len: 6)
  end

  def encode(val) when is_number(val) and val >= 0 do
    Hashids.encode(hashid(), val)
  end

  def encode(val) when is_binary(val) do
    encode(String.to_integer(val))
  end

  def decode(hashid) do
    Hashids.decode!(hashid(), hashid) |> hd
  end
end
