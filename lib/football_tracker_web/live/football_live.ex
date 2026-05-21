defmodule FootballTrackerWeb.FootballLive do
  @moduledoc """
  Main LiveView for the Premier League tracker.
  """

  use FootballTrackerWeb, :live_view

  alias FootballTracker.PremierLeaguePoller

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(FootballTracker.PubSub, PremierLeaguePoller.topic())
    end

    initial_state = get_initial_state()

    {:ok,
     socket
     |> assign(:standings, initial_state.standings)
     |> assign(:results, initial_state.results)
     |> assign(:fixtures, initial_state.fixtures)
     |> assign(:last_updated, initial_state.last_updated)
     |> assign(:active_tab, "standings")
     |> assign(:loading, initial_state.standings == [])}
  end

  @impl true
  def handle_info({:update, data}, socket) do
    {:noreply,
     socket
     |> assign(:standings, data.standings)
     |> assign(:results, data.results)
     |> assign(:fixtures, data.fixtures)
     |> assign(:last_updated, data.last_updated)
     |> assign(:loading, false)}
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
  end

  # ── Helpers ───────────────────────────────────────────────────

  defp get_initial_state do
    case GenServer.whereis(PremierLeaguePoller) do
      nil -> %{standings: [], results: [], fixtures: [], last_updated: nil}
      pid -> :sys.get_state(pid)
    end
  end

  # ── View Helpers ──────────────────────────────────────────────

  def zone_class(pos) do
    cond do
      pos <= 4  -> "zone-cl"
      pos == 5  -> "zone-el"
      pos >= 18 -> "zone-rel"
      true      -> "zone-none"
    end
  end

  def gd_class(gd) do
    cond do
      gd > 0  -> "gd-pos"
      gd < 0  -> "gd-neg"
      true    -> "gd-zero"
    end
  end

  def form_dot_class(char) do
    case char do
      "W" -> {"Win",  "W"}
      "D" -> {"Draw", "D"}
      "L" -> {"Loss", "L"}
      _   -> {char,   "unknown"}
    end
  end

  # Returns winner/loser CSS class for match team name
  def winner_class(score_a, score_b, _side) when is_nil(score_a) or is_nil(score_b), do: ""
  def winner_class(score_a, score_b, _side) do
    cond do
      score_a > score_b -> "match-team-name--winner"
      score_a < score_b -> "match-team-name--loser"
      true              -> ""
    end
  end

  # Returns score number CSS class
  def score_class(score_a, score_b, _side) when is_nil(score_a) or is_nil(score_b), do: "score-num--neutral"
  def score_class(score_a, score_b, _side) do
    cond do
      score_a > score_b -> "score-num--winner"
      score_a < score_b -> "score-num--loser"
      true              -> "score-num--neutral"
    end
  end

  def format_datetime(nil), do: "—"
  def format_datetime(date) do
    case Date.from_iso8601(date) do
      {:ok, d} -> Calendar.strftime(d, "%d %b")
      _        -> date
    end
  end
end
