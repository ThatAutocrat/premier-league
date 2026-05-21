import Config

config :logger, level: :info

config :football_tracker, FootballTrackerWeb.Endpoint,
  server: true,
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT") || "4000")],
  url: [host: System.get_env("PHX_HOST") || "localhost", port: 443, scheme: "https"],
  secret_key_base: System.get_env("SECRET_KEY_BASE") || raise("SECRET_KEY_BASE missing")
