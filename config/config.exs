# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :planet,
  ecto_repos: [Planet.Repo]

# Configures the endpoint
config :planet, PlanetWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: PlanetWeb.ErrorHTML, json: PlanetWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Planet.PubSub,
  live_view: [signing_salt: "tPMgEeKF"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :planet, Planet.Mailer,
  adapter: Swoosh.Adapters.Local,
  app_name: "Planet",
  sender_name: "Shap",
  sender_email: "shap@planet.com",
  # 100px
  icon: "https://i.pravatar.cc/150?u=men"

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :planet, Oban,
  peer: Oban.Peers.Postgres,
  repo: Planet.Repo,
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       #  {"* * * * *", Planet.Jobs.DummyJob}
     ]},
    {Oban.Plugins.Pruner, max_age: 86_400 * 40}
  ],
  queues: [
    default: 10
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Added

# # Need to move these to prod and dev respectively
# config :stripy,
#   # stripe development key
#   secret_key: "sk_test_LTxLpQv9BFYdWI6ulWA0J51Z",
#   publish_key: "pk_test_Xvhna4CeSxcU8hywnhPcRCLR",
#   # All these attributes being inside conn,
#   # we can pattern match against them.
#   # request_path is a good fit but it
#   # may contain trailing slashes.
#   # Instead, path_info is a list of each segment in the path,
#   #  so we don’t have to bother with slashes at all,
#   #  making it a better choice here.
#   webhook_endpoint_info: ["webhook", "stripe"],
#   webhook_secret: "whsec_NHSDIddjRRHz8Cseevhm74Fhoq13PSY9",
#   cancel_url: ["settings", "billing"],
#   success_url: ["settings", "billing"],
#   return_url: ["settings", "billing"],
#   on_create_plan_price_id: "price_free_id_monthly",
#   # optional
#   endpoint: "https://api.stripe.com/v1/",
#   # optional
#   version: "2020-08-27",
#   # optional
#   httpoison: [recv_timeout: 5000, timeout: 8000]

# [Release] Check Production Or Runtime Variables
config :planet, :paddle,
  # If Unpaid Access Is Allowed, Can Perform Tasks without Active Status
  # No Billing Required
  # If False -> Redirect To Billing Page
  # Can be Read as Allow_Free_Access
  allow_unpaid_access: true,
  sandbox: true,
  api_key: "3071a1d8b877b7325866d3ece8857018",
  vendor_id: 13057,
  bank_statement: "PADDLE.NET* RINKO",
  ip_whitelist: [
    "34.194.127.46",
    "54.234.237.108",
    "3.208.120.145",
    "44.226.236.210",
    "44.241.183.62",
    "100.20.172.113",
    "127.0.0.1"
  ],
  webhook_secret_key: "pdl_ntfset_01jczc5vydss955aacd0z4yphp_Qt2m7phZuwzI70qWldEWpfoGb3fzuZG1",
  client_key: "test_89a7fedf85d036d2351afdafa35",
  billing_api_key: "5a8ddb7c702b9ba0608a94b109e37f34c947b97b1d81b7c29f",
  public_key: """
  -----BEGIN PUBLIC KEY-----
  MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEArYwvvhCBpT956KQ7qUJ/
  7RNcI9rEwwMfR1XbJSJdDOsI8WEIvnXvlHTYbtESry4h9Il+5xFhIcpjP9SpC+LL
  LWnJk+g+kQ5INE3jlABZc3hgMzN9/zgUwuQ7FiCukRvwQmxUTMIt/O2Y27l+zpWe
  450mPg7qqqhobPrkm+HL2xqNPK0rBOEryCx217ifvdMSORMw1NORm5c8wbxtayMf
  4pScjzyz2Xb8NXLkdV2FAu0oUFrQQlQoMiWMhQJYxI/fB+51k0XYHN5qurQo9Vsn
  hR4pGHf8gpYY1JZ/sJtJKI1DW5k14pNq8nP8G2OlPHSg4RNzMpgnuaKFdvTDCgKa
  jYRSS1pqU+TumYWX3+5hRxtOfZ/Lhuk0d/vrd0IIGMhzsY+NDdjb0UNYVQlY38lX
  OgxbX5BM7G8+xyP+gtEkOhVWihnSv1IqhIXWvsRiZ1Uq86szerGdvjKTGHJ5lCCb
  O6qXA+H9pH2SbG37KhQsPCETDMoAn8VaB8Yzgt11daCNEfGeBFrQD7sF0d9wGhjq
  1UVjwVbjD9q1T3mgp4SpQZXxZX449phtl0r8ONrdtVIIDIzW0TabLB3vQDoikICO
  mOQ/2uOU0uuJSPwrYYLTjWWbziovMphTU9VpZbx3AOy2XL+HejxNZQWYZnQF089l
  6w/lkLugrM5x0h7+6Vj3rOUCAwEAAQ==
  -----END PUBLIC KEY-----
  """

# [Release] Check Production Or Runtime Variables
# config :wax_,
#   origin: "https://658c7343cc71-11974691996598043146.ngrok-free.app",
#   rp_id: :auto,
#   update_metadata: true,
#   metadata_dir: :planet,
#   attestation: "none"

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [include_granted_scopes: true]},
    github: {Ueberauth.Strategy.Github, [default_scope: "user:email,read:user"]}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: "291426313678-e9hoqf9e86cmsuj72pdqdokdugoael0o.apps.googleusercontent.com",
  # System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: "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"

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: "Ov23liyScVeXFSbUeUEp",
  client_secret: "30956260a7015511ca56fc14f4ab13eeb7f64449"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
