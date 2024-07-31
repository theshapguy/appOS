defmodule PlanetWeb.UserSettingsHTML do
  use PlanetWeb, :html

  embed_templates "user_settings_html/*"

  def humanize_timezone_list() do
    # Tzdata.zone_list()
    # |> Enum.map(fn x ->
    #   {x, "#{x} (GMT #{Timex.now(x) |> Timex.format!("%z", :strftime)})"}
    # end)

    now = DateTime.utc_now()

    Tzdata.zone_list()
    |> Enum.map(fn zone ->
      tzinfo = Timex.Timezone.get(zone, now)
      # added in v3.78
      offset = Timex.TimezoneInfo.format_offset(tzinfo)
      label = "#{tzinfo.full_name} - #{tzinfo.abbreviation} (#{offset})"

      {tzinfo.full_name, label}
    end)
    |> Enum.uniq()

    # Tzdata.zone_lists_grouped()
    # |> Map.drop([:backward])
    # |>
  end
end
