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
  # adapter: Phoenix.Endpoint.Cowboy2Adapter,
  adapter: Bandit.PhoenixAdapter,
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
  icon: "https://i.pravatar.cc/150?u=men",
  hostname: "planet.com",
  company_name: "Planet Inc.",
  support_email: "help@planet.inc"


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
config :mnesia, dir: ~c"mnesia/#{Mix.env()}/#{node()}"

# [Release] Check Production Or Runtime Variables
config :planet, :payment,
  sandbox?: false,
  processor: :stripe,
  # If Free Plan Allows Access, Don't Redirect to Billing Page On Free Plan
  allow_free_plan_access: true


config :planet, :stripe,
  description: "Stripe. Secure payment processing.",
  client_key: "pk_test_Xvhna4CeSxcU8hywnhPcRCLR",
  api_key: "sk_test_LTxLpQv9BFYdWI6ulWA0J51Z",
  webhook_secret_key: "whsec_kT9OoRnIbrZCke6PbFkVdxQ3a2KDSjMo",
  api_endpoint: "https://api.stripe.com/v1",
  portal_endpoint: "https://billing.stripe.com/p/login/test_cN28xS7YC7LM53ieUU",
  vat_included: true,
  bank_statement: "SOCIAL REECH CRM",
  version: "2024-11-20.acacia"

config :planet, :paddle,
  description: "Paddle. Secure payment processing.",
  client_key: "test_89a7fedf85d036d2351afdafa35",
  api_key: "5a8ddb7c702b9ba0608a94b109e37f34c947b97b1d81b7c29f",
  webhook_secret_key: "pdl_ntfset_01jczc5vydss955aacd0z4yphp_Qt2m7phZuwzI70qWldEWpfoGb3fzuZG1",
  api_endpoint: "https://sandbox-api.paddle.com",
  portal_endpoint: "https://sandbox-customer-portal.paddle.com/cpl_01h411b80rvpnhgcb87qktvg1n",
  vat_included: false,
  bank_statement: "PADDLE.NET* RINKO"

config :planet, :creem,
  description: "Creem.io, manages your transaction as Merchant of Record, leveraging Stripe's secure payment infrastructure.",
  # client_key: nil,
  api_key: "creem_test_1Q3elUpPD3j2KpatJAWcon",
  webhook_secret_key: "whsec_7b8GNm0PQSlBfWMRb8Ohpd",
  api_endpoint: "https://test-api.creem.io/v1",
  portal_endpoint: "https://www.creem.io/test/my-orders/login",
  vat_included: false,
  bank_statement: "CREEM.IO SOCIALREECH"


# config :planet, :processor_name,
#   description: "Processor Name",
#   client_key: "",
#   api_key: "",
#   webhook_secret_key: "",
#   api_endpoint: "",
#   portal_endpoint: "",
#   vat_included: true,
#   bank_statement: "SOCIAL REECH CRM",
#   version: "2024-11-20.acacia"

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
