defmodule Planet.Utils do
  @salt "GfZxhzXYRsk6Flz9ysXvQFmdUhPMpGl"

  def encrypt_string(string) do
    Phoenix.Token.sign(PlanetWeb.Endpoint, @salt, string)
    |> Base.encode64(padding: false)
  end

  def decrypt_string(token) do
    {:ok, decrypted} =
      token
      |> Base.decode64!(padding: false)
      |> (&Phoenix.Token.verify(PlanetWeb.Endpoint, @salt, &1, max_age: 86400)).()

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
end
