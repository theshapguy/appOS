defmodule Planet.Utils do
  @salt "GfZxhzXYRsk6Flz9ysXvQFmdUhPMpGl"

  def print_sql(queryable, repo \\ Repo) do
    IO.inspect(Ecto.Adapters.SQL.to_sql(:all, repo, queryable))
    queryable
  end

  def encrypt_string(string, conn \\ PlanetWeb.Endpoint) do
    Phoenix.Token.sign(conn, @salt, string)
    |> Base.encode64(padding: false)
  end

  # Max Age 100 years; Use Token Like It Never Expires
  def decrypt_string(token, conn \\ PlanetWeb.Endpoint, max_age \\ 3_153_600_000) do
    token
    |> Base.decode64!(padding: false)
    |> (&Phoenix.Token.verify(conn, @salt, &1, max_age: max_age)).()
  end

  def decrypt_string!(token, conn \\ PlanetWeb.Endpoint, max_age \\ 3_153_600_000) do
    {:ok, decrypted} = decrypt_string(token, conn, max_age)
    decrypted
  end

  def traverse_changeset_errors(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def traverse_changeset_errors_for_flash(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {key, errors} ->
      "#{key}: #{Enum.join(errors, ", ")}"
    end)
    |> Enum.join("\n")
  end

  def string_to_attrs(str) do
    str
    |> String.split(",", trim: true)
    |> Enum.reduce(%{}, fn pair, acc ->
      [key, value] = String.split(pair, "=", trim: true)
      Map.put(acc, key, value)
    end)
  end

  def convert(map) when is_map(map) do
    map
    |> Enum.map(fn {k, v} -> {k, convert_value(v)} end)
    |> Map.new()
  end

  defp convert_value(%{__struct__: _} = struct) do
    struct
    |> Map.from_struct()
    |> convert()
  end

  defp convert_value(map) when is_map(map), do: convert(map)
  defp convert_value(list) when is_list(list), do: Enum.map(list, &convert_value/1)
  defp convert_value(value), do: value

  def generate_random_string(length \\ 50) do
    :crypto.strong_rand_bytes(length)
    |> Base.encode64()
    |> binary_part(0, length)
  end
end
