import Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix assets.deploy` task,
# which you should run after static files are built and
# before starting your production server.
config :appOS, AppOSWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: AppOS.Finch

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.

# TODO Configure Before Going Live
config :appOS, :paddle,
  sandbox: false,
  api_key: "3071a1d8b877b7325866d3ece8857018",
  vendor_id: 13057,
  bank_statement: "PADDLE.NET* RINKO",
  ip_whitelist: [
    "34.232.58.13",
    "34.195.105.136",
    "34.237.3.244",
    "35.155.119.135",
    "52.11.166.252",
    "34.212.5.7"
  ],
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

# [Release] Check Runtime As Well
