import Config

config :football_tracker, FootballTrackerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "dev_secret_key_base_at_least_64_chars_long_xxxxxxxxxxxxxxxxxxxxxxxxxxx",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:football_tracker, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:football_tracker, ~w(--watch)]}
  ]

config :football_tracker, FootballTrackerWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/football_tracker_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :logger, :console, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
config :phoenix_live_view, :debug_heex_annotations, true
