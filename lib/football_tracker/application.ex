defmodule FootballTracker.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FootballTrackerWeb.Telemetry,
      {Phoenix.PubSub, name: FootballTracker.PubSub},
      FootballTrackerWeb.Endpoint,
      # Our GenServer that polls TheSportsDB every 60 seconds
      FootballTracker.PremierLeaguePoller
    ]

    opts = [strategy: :one_for_one, name: FootballTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    FootballTrackerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
