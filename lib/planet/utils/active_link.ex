defmodule Planet.Helpers.ActiveLink do
  @moduledoc """
  Active Link provides helpers to add active links in views.

  ## Integrate in Phoenix

  The simplest way to add the helpers to Phoenix is to `import PhoenixActiveLink`
  either in your `web.ex` under views to have it available under every views,
  or under for example `App.LayoutView` to have it available in your layout.
  """

  # https://github.com/danhper/phoenix-active-link
  #  Copyright (c) 2016 Daniel Perez
  # Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
  # The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
  # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  import Plug.Conn
  alias Plug.Conn.Query

  @doc """
  `active_path?/2` is a helper to determine if the element should be in active state or not.

  The `:opts` should contain the `:to` option and the active detection can be customized
  using by passing `:active` one of the following values.

    * `true`       - Will always return `true`
    * `false`      - Will always return `false`
    * `:inclusive` - Will return `true` if the current path starts with the link path.

      For example, `active_path?(conn, to: "/foo")` will return `true` if the path is `"/foo"` or `"/foobar"`.
    * `:exclusive` - Will return `true` if the current path and the link path are the same,
       but will ignore the trailing slashes

       For example, `active_path?(conn, "/foo")` will return `true`
       when the path is `"/foo/"`
    * `:exact`     - Will return `true` if the current path and the link path are exactly the same,
       including trailing slashes.
    * a `%Regex{}` - Will return `true` if the current path matches the regex.

        Beware that `active?(conn, active: ~r/foo/)` will return `true` if the path is `"/bar/foo"`, so
       you must use `active?(conn, active: ~r/^foo/)` if you want to match the beginning of the path.
    * a `{controller, action}` list - A list of tuples with a controller module and an action symbol.

        Both can be the `:any` symbol to match any controller or action.
    * a `{live_view, action}` list - A list of tuples with a live view module and an action symbol.

        Both can be the `:any` symbol to match any live view module or action.
    * `:exact_with_params`     - Will return `true` if the current path and the link path are exactly the same,
       including trailing slashes and query string as is.

    * `:inclusive_with_params` - Will return `true` if the current path is equal to the link path and the query params of the current path are included to the link path.
        For example, `active_path?(conn, to: "/foo?bar=2")` will return `true` if the path is `"/foo?bar=2"` or `"/foo?baz=2&bar=2"`.
        For example, `active_path?(conn, to: "/foo?bar=2")` will return `false` if the path is `"/foobaz?bar=2"`.

  ## Examples

  ```elixir
  active_path?(conn, to: "/foo")
  active_path?(conn, to: "/foo", active: false)
  active_path?(conn, to: "/foo", active: :exclusive)
  active_path?(conn, to: "/foo", active: ~r(^/foo/[0-9]+))
  active_path?(conn, to: "/foo", active: [{MyController, :index}, {OtherController, :any}])
  active_path?(conn, to: "/foo", active: [{MyLive, :index}, {OtherLive, :any}])
  active_path?(conn, to: "/foo?baz=2", active: :inclusive_with_params)
  ```

  """
  def active_path?(conn, opts) do
    to = Keyword.get(opts, :to, "")

    case Keyword.get(opts, :active, :inclusive) do
      true ->
        true

      false ->
        false

      :inclusive ->
        starts_with_path?(conn.request_path, to)

      :exclusive ->
        String.trim_trailing(conn.request_path, "/") == String.trim_trailing(to, "/")

      :exact ->
        conn.request_path == to

      :exact_with_params ->
        request_path_with_params(conn) == to

      :inclusive_with_params ->
        compare_path_and_params(conn, to)

      %Regex{} = regex ->
        Regex.match?(regex, conn.request_path)

      module_actions when is_list(module_actions) ->
        module_actions_active?(conn, module_actions)

      _ ->
        false
    end
  end

  # NOTE: root path is an exception, otherwise it would be active all the time
  defp starts_with_path?(request_path, "/") when request_path != "/", do: false

  defp starts_with_path?(request_path, to) do
    # Parse both paths to strip any query parameters
    %{path: request_path} = URI.parse(request_path)
    %{path: to_path} = URI.parse(to)

    String.starts_with?(request_path, String.trim_trailing(to_path, "/"))
  end

  defp module_actions_active?(conn, module_actions) do
    {current_module, current_action} =
      case conn.private do
        %{phoenix_controller: module, phoenix_action: action} -> {module, action}
        %{phoenix_live_view: {module, opts}} -> {module, Keyword.get(opts, :action)}
        %{} -> {nil, nil}
      end

    Enum.any?(module_actions, fn {module, action} ->
      (module == :any or module == current_module) and
        (action == :any or action == current_action)
    end)
  end

  defp request_path_with_params(conn) do
    case conn.query_string do
      "" -> conn.request_path
      query_string -> conn.request_path <> "?" <> query_string
    end
  end

  defp compare_path_and_params(conn, to) do
    %{query_params: request_params} = fetch_query_params(conn)

    with [path, query_params] <- String.split(to, "?"),
         true <- starts_with_path?(conn.request_path, path) do
      decoded_params =
        query_params
        |> Query.decode()

      map_include?(request_params, decoded_params)
    else
      [path] -> conn.request_path == path
      false -> false
    end
  end

  defp map_include?(map, {key, %{} = value}), do: map_include?(map[key], value)
  defp map_include?(map, {key, value}), do: map[key] == value
  defp map_include?(in_map, %{} = map), do: Enum.all?(map, &map_include?(in_map, &1))
end
