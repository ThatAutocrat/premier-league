# ⚽ Premier League Tracker

A real-time Premier League tracker built with **Elixir + Phoenix LiveView**.

Live standings, recent results, and upcoming fixtures — all updating automatically every 60 seconds via WebSockets. No page refreshes, no JS state management, no REST polling from the browser.

## How it works

```
TheSportsDB API
      │
      ▼ (every 60s)
GenServer (PremierLeaguePoller)
      │
      ▼ Phoenix.PubSub.broadcast/3
LiveView sessions (all connected browsers)
      │
      ▼ server-side diff
Browser (only changed HTML pushed over WebSocket)
```

Three files do all the work:
- `lib/football_tracker/premier_league_poller.ex` — fetches data, broadcasts it
- `lib/football_tracker_web/live/football_live.ex` — receives data, holds state
- `lib/football_tracker_web/live/football_live.html.heex` — renders it

## Requirements

- Elixir 1.14+
- Erlang/OTP 25+
- Node.js 18+ (for asset compilation)

Install Elixir: https://elixir-lang.org/install.html

## Setup

```bash
# Install dependencies
mix setup

# Start the server
mix phx.server
```

Visit http://localhost:4000

## Features

- **Standings table** — all 20 clubs, points, GD, form dots (W/D/L)
- **Results** — last 10 Premier League matches with scores
- **Fixtures** — next 10 upcoming matches
- **Live updates** — data refreshes every 60 seconds via PubSub → LiveView
- **Visual cues** — blue/orange/red left borders for CL / Europa / relegation positions

## API

Data comes from [TheSportsDB](https://www.thesportsdb.com) free tier — no API key or sign-up needed.

- Premier League ID: `4328`
- Standings: `/lookuptable.php?l=4328&s=2023-2024`
- Results: `/eventspastleague.php?id=4328`
- Fixtures: `/eventsnextleague.php?id=4328`

## Customising

**Change the league:** Update `@league_id` and `@season` in `premier_league_poller.ex`.
Common league IDs:
- Premier League: `4328`
- La Liga: `4335`
- Bundesliga: `4331`
- Serie A: `4332`
- Ligue 1: `4334`

**Change the poll interval:** Update `@poll_interval` in `premier_league_poller.ex`.

**Add more data:** The GenServer state map is easy to extend — add a new fetcher function, add the key to the broadcast, and add a new tab in the LiveView template.

## Deployment

```bash
# Generate a secret key
mix phx.gen.secret

# Set environment variables
export SECRET_KEY_BASE=<your_secret>
export PHX_HOST=yourdomain.com

# Build and run
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix phx.server
```

For Docker/Fly.io deployment, see the [Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).
