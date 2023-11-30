defmodule PlanetWeb.EmailHTML do
  # use PlanetWeb, :html
  import Phoenix.Template, only: [embed_templates: 2]
  # https://github.com/swoosh/phoenix_swoosh/issues/287#issuecomment-1592765423
  # import Phoenix.Template, only: [embed_templates: 2]

  # embed_templates "templates/email/*"

  embed_templates("templates/email/*.html", suffix: "_html")
  embed_templates("templates/email/*.text", suffix: "_text")
end
