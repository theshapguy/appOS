defmodule Planet.HTTPRequest do
  @moduledoc """
  A custom HTTP client that sets default headers for all requests.
  """

  @default_headers [
    {"User-Agent",
     "#{Application.compile_env(:planet, Planet.Mailer)[:app_name]}/#{Planet.MixProject.user_agent_version()}"}
  ]

  def get(url, headers \\ [], options \\ []) do
    HTTPoison.get(url, merge_headers(headers), options)
  end

  def post(url, body, headers \\ [], options \\ []) do
    HTTPoison.post(url, body, merge_headers(headers), options)
  end

  def put(url, body, headers \\ [], options \\ []) do
    HTTPoison.put(url, body, merge_headers(headers), options)
  end

  def delete(url, headers \\ [], options \\ []) do
    HTTPoison.delete(url, merge_headers(headers), options)
  end

  defp merge_headers(headers) do
    @default_headers ++ headers
  end
end
