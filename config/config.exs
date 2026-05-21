import Config

config :football_tracker,
  generators: [timestamp_type: :utc_datetime]

config :football_tracker, FootballTrackerWeb.Endpoint,
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: FootballTrackerWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: FootballTracker.PubSub,
  live_view: [signing_salt: "wX9kL3nM"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :tailwind,
  version: "4.1.12",
  football_tracker: [
    args: ~w(
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :esbuild,
  version: "0.25.0",
  football_tracker: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

import_config "#{config_env()}.exs"
