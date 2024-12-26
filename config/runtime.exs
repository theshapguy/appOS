import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/planet start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.

if System.get_env("PHX_SERVER") do
  config :planet, PlanetWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :planet, Planet.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  # host = System.get_env("PHX_HOST") || "example.com"
  host =
    System.get_env("PHX_HOST") ||
      raise """
      environment variable PHX_HOST is missing.
      """

  port = String.to_integer(System.get_env("PORT") || "4000")

  config :planet, PlanetWeb.Endpoint,
    # Used To Generate URL In Static URL/Images
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 1},
      port: port
    ],
    secret_key_base: secret_key_base

  mnesia_db_location =
    System.get_env("MNESIA_DB_DIR") ||
      raise """
      environment variable MNESIA_DB_DIR is missing.
      Please point to a directory where Mnesia can store its database.
      """

  config :mnesia, dir: ~c"#{mnesia_db_location}"

  config :ueberauth, Ueberauth.Strategy.Google.OAuth,
    client_id:
      System.get_env("GOOGLE_CLIENT_ID") ||
        raise("""
        environment variable GOOGLE_CLIENT_ID is missing.
        """),
    client_secret:
      System.get_env("GOOGLE_CLIENT_SECRET") ||
        raise("""
        environment variable GOOGLE_CLIENT_SECRET is missing.
        """)

  config :ueberauth, Ueberauth.Strategy.Github.OAuth,
    client_id:
      System.get_env("GITHUB_CLIENT_ID") ||
        raise("""
        environment variable GITHUB_CLIENT_ID is missing.
        """),
    client_secret:
      System.get_env("GITHUB_CLIENT_SECRET") ||
        raise("""
        environment variable GITHUB_CLIENT_SECRET is missing.
        """)

  config :planet, Planet.Mailer,
    adapter: Swoosh.Adapters.Mailgun,
    api_key:
      System.get_env("MAILGUN_API_KEY") ||
        raise("""
        environment variable MAILGUN_API_KEY is missing.
        """),
    domain:
      System.get_env("MAILGUN_DOMAIN") ||
        raise("""
        environment variable MAILGUN_DOMAIN is missing.
        """),
    app_name:
      System.get_env("APP_NAME") ||
        raise("""
        environment variable MAILGUN_DOMAIN is missing.
        """),
    sender_name: "Shap",
    sender_email: "shap@#{host}",
    # 100px
    # Upload to Cloudflare and Set Icon Here
    icon:
      System.get_env("APP_EMAIL_LOGO_URL") ||
        raise("""
        environment variable APP_EMAIL_LOGO_URL is missing.
        """),
    hostname: "#{host}",
    company_name:
      System.get_env("APP_COMPANY_NAME") ||
        raise("""
        environment variable APP_COMPANY_NAME is missing.
        """),
    support_email: "help@#{host}",
    # Notify URL for Planet, using ntfy.sh
    ntfy_url:
      System.get_env("NFTY_URL") ||
        raise("""
        environment variable NFTY_URL is missing.
        """)

  case Application.compile_env(:planet, :payment)
       |> Keyword.fetch!(:processor) do
    :creem ->
      config :planet, :creem,
        api_key:
          System.get_env("CREEM_API_KEY") ||
            raise("""
            environment variable CREEM_API_KEY is missing.
            """),
        webhook_secret_key:
          System.get_env("CREEM_WEBHOOK_SECRET_KEY") ||
            raise("""
            environment variable CREEM_WEBHOOK_SECRET_KEY is missing.
            """),
        api_endpoint: "https://api.creem.io/v1",
        portal_endpoint: "https://www.creem.io/my-orders/login"

    :paddle ->
      config :planet, :paddle,
        client_key:
          System.get_env("PADDLE_CLIENT_KEY") ||
            raise("""
            environment variable PADDLE_CLIENT_KEY is missing.
            """),
        api_key:
          System.get_env("PADDLE_API_KEY") ||
            raise("""
            environment variable PADDLE_API_KEY is missing.
            """),
        webhook_secret_key:
          System.get_env("PADDLE_WEBHOOK_SECRET_KEY") ||
            raise("""
            environment variable PADDLE_WEBHOOK_SECRET_KEY is missing.
            """),
        api_endpoint: "https://api.paddle.com",
        # PROD-TODO Change In Production
        portal_endpoint: "https://customer-portal.paddle.com/cpl_01h411b80rvpnhgcb87qktvg1n"

    :stripe ->
      config :planet, :stripe,
        api_key:
          System.get_env("STRIPE_API_KEY") ||
            raise("""
            environment variable STRIPE_API_KEY is missing.
            """),
        webhook_secret_key:
          System.get_env("STRIPE_WEBHOOK_SECRET_KEY") ||
            raise("""
            environment variable STRIPE_WEBHOOK_SECRET_KEY is missing.
            """),
        # PROD-TODO Change In Production
        portal_endpoint: "https://billing.stripe.com/p/login/test_cN28xS7YC7LM53ieUU"

    _ ->
      raise "Payment Processor Not Supported"
  end

  # PROD-TODO Change In Production
  # config :wax_,
  #   origin: host,
  #   rp_id: :auto,
  #   update_metadata: true,
  #   metadata_dir: :planet,
  #   attestation: "none"

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :planet, PlanetWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your endpoint, ensuring
  # no data is ever sent via http, always redirecting to https:
  #
  #     config :planet, PlanetWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :planet, Planet.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
