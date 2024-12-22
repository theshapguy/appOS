defmodule Planet.Utils.RemoteIP do
  @moduledoc """
  Implements the strategy of retrieving client's remote IP
  """

  # Removes port from both IPv4 and IPv6 addresses. From https://regexr.com/3hpvt
  # Removes surrounding [] of an IPv6 address
  @port_regex ~r/((\.\d+)|(\]))(?<port>:[0-9]+)$/

  def get(conn) do
    headers_with_parsers = [
      {"cf-connecting-ip", &clean_ip/1},
      {"b-forwarded-for", &parse_forwarded_for/1},
      {"x-forwarded-for", &parse_forwarded_for/1},
      {"forwarded", &parse_forwarded_header/1}
    ]

    headers_with_parsers
    |> Enum.find_value(fallback_ip(conn), fn {header, parser} ->
      case Plug.Conn.get_req_header(conn, header) do
        [value | _] when byte_size(value) > 0 -> parser.(value)
        _ -> nil
      end
    end)
  end

  defp fallback_ip(conn) do
    fn -> conn.remote_ip |> :inet_parse.ntoa() |> to_string() end
  end

  defp parse_forwarded_header(forwarded) do
    # https://datatracker.ietf.org/doc/html/rfc7239
    with %{"for" => ip} <- Regex.named_captures(~r/for=(?<for>[^;,]+).*$/, forwarded) do
      ip
      |> String.trim("\"")
      |> clean_ip()
    end
  end

  defp parse_forwarded_for(header) do
    header
    |> String.split(",")
    |> List.first()
    |> String.trim()
    |> clean_ip()
  end

  defp clean_ip(ip_and_port) do
    ip =
      case Regex.named_captures(@port_regex, ip_and_port) do
        %{"port" => port} -> String.trim_trailing(ip_and_port, port)
        _ -> ip_and_port
      end

    ip
    |> String.trim_leading("[")
    |> String.trim_trailing("]")
  end
end
