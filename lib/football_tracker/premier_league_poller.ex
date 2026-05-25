defmodule FootballTracker.PremierLeaguePoller do
  @moduledoc """
  GenServer that polls TheSportsDB every 60 seconds for:
    - Premier League standings
    - Recent match results
    - Upcoming fixtures

  Broadcasts updates via Phoenix.PubSub so all connected LiveView
  sessions update simultaneously without any extra work.
  """

  use GenServer
  require Logger

  # Premier League ID on TheSportsDB
  @league_id "4328"
  @season "2025-2026"
  @poll_interval :timer.seconds(60)
  @pubsub_topic "premier_league"
  @base_url "https://www.thesportsdb.com/api/v1/json/3"

  # ── Public API ────────────────────────────────────────────────

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def topic, do: @pubsub_topic

  # ── GenServer Callbacks ───────────────────────────────────────

  @impl true
  def init(_state) do
    Logger.info("[PremierLeaguePoller] Starting up...")
    send(self(), :fetch)
    {:ok, %{standings: [], results: [], fixtures: [], last_updated: nil}}
  end

  @impl true
  def handle_info(:fetch, state) do
    Logger.info("[PremierLeaguePoller] Fetching data from TheSportsDB...")

    new_state =
      state
      |> Map.put(:standings, fetch_standings())
      |> Map.put(:results, fetch_results())
      |> Map.put(:fixtures, fetch_fixtures())
      |> Map.put(:last_updated, DateTime.utc_now())

    Phoenix.PubSub.broadcast(
      FootballTracker.PubSub,
      @pubsub_topic,
      {:update, new_state}
    )

    Process.send_after(self(), :fetch, @poll_interval)

    {:noreply, new_state}
  end

  # ── Fetchers ──────────────────────────────────────────────────

  defp fetch_standings do
    url = "#{@base_url}/lookuptable.php?l=#{@league_id}&s=#{@season}"

    case HTTPoison.get(url, [], recv_timeout: 10_000) do
      {:ok, %{status_code: 200, body: body}} ->
        body
        |> Jason.decode!()
        |> Map.get("table", [])
        |> Enum.map(&parse_standing/1)

      {:error, reason} ->
        Logger.error("[PremierLeaguePoller] Standings fetch failed: #{inspect(reason)}")
        []
    end
  end

  defp fetch_results do
    url = "#{@base_url}/eventspastleague.php?id=#{@league_id}"

    case HTTPoison.get(url, [], recv_timeout: 10_000) do
      {:ok, %{status_code: 200, body: body}} ->
        body
        |> Jason.decode!()
        |> Map.get("events", [])
        |> Enum.take(10)
        |> Enum.map(&parse_event/1)

      {:error, reason} ->
        Logger.error("[PremierLeaguePoller] Results fetch failed: #{inspect(reason)}")
        []
    end
  end

  defp fetch_fixtures do
    url = "#{@base_url}/eventsnextleague.php?id=#{@league_id}"

    case HTTPoison.get(url, [], recv_timeout: 10_000) do
      {:ok, %{status_code: 200, body: body}} ->
        body
        |> Jason.decode!()
        |> Map.get("events", [])
        |> Enum.take(10)
        |> Enum.map(&parse_event/1)

      {:error, reason} ->
        Logger.error("[PremierLeaguePoller] Fixtures fetch failed: #{inspect(reason)}")
        []
    end
  end

  # ── Parsers ───────────────────────────────────────────────────

  defp parse_standing(row) do
    %{
      position:       to_int(row["intRank"]),
      team:           row["strTeam"],
      team_badge:     row["strTeamBadge"],
      played:         to_int(row["intPlayed"]),
      won:            to_int(row["intWin"]),
      drawn:          to_int(row["intDraw"]),
      lost:           to_int(row["intLoss"]),
      goals_for:      to_int(row["intGoalsFor"]),
      goals_against:  to_int(row["intGoalsAgainst"]),
      goal_diff:      to_int(row["intGoalDifference"]),
      points:         to_int(row["intPoints"]),
      form:           row["strForm"] || ""
    }
  end

  defp parse_event(event) do
    %{
      id:           event["idEvent"],
      home_team:    event["strHomeTeam"],
      away_team:    event["strAwayTeam"],
      home_score:   to_score(event["intHomeScore"]),
      away_score:   to_score(event["intAwayScore"]),
      date:         event["dateEvent"],
      time:         event["strTime"],
      status:       event["strStatus"],
      round:        event["intRound"],
      home_badge:   event["strHomeTeamBadge"],
      away_badge:   event["strAwayTeamBadge"]
    }
  end

  defp to_int(nil), do: 0
  defp to_int(val) when is_integer(val), do: val
  defp to_int(val) when is_binary(val) do
    case Integer.parse(val) do
      {n, _} -> n
      :error -> 0
    end
  end

  # scores can be nil for upcoming matches
  defp to_score(nil), do: nil
  defp to_score(val) when is_integer(val), do: val
  defp to_score(val) when is_binary(val) do
    case Integer.parse(val) do
      {n, _} -> n
      :error -> nil
    end
  end
end
