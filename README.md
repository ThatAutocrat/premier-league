# ⚽Premier League Tracker

> **Live standings. Real-time results. Zero page refreshes.** <br>
> Open the page. The table is there. Someone scores. Your screen updates. You didn't touch anything. That's it.

Built with **Elixir + Phoenix LiveView** — the server holds all the state, renders all the HTML, and pushes only what changed over a WebSocket. No JS framework. No REST polling from the browser. No F5.

---

## 🤔 What is this?

A football dashboard with three things:

| Tab | What it shows |
|-----|---------------|
| 🏆 **Standings** | All 20 clubs — points, goal difference, last-5 form dots (🟢 W / ⚫ D / 🔴 L) |
| ⚡ **Results** | Last 10 Premier League matches with scores |
| 📅 **Fixtures** | Next 10 upcoming matches |

Visual cues on the standings table:
- 🔵 Blue left border = Champions League places
- 🟠 Orange left border = Europa League
- 🔴 Red left border = Relegation zone

Data refreshes **every 60 seconds** automatically. All connected browsers update simultaneously.

---

## 🧠 How it works (plain English)

```
TheSportsDB API  (free, no sign-up)
      │
      ▼  every 60 seconds
GenServer (PremierLeaguePoller)   ← wakes up, fetches fresh data
      │
      ▼  Phoenix.PubSub.broadcast/3
All connected LiveView sessions   ← all browsers subscribed
      │
      ▼  server-side HTML diff
Browser                           ← receives only the changed bits over WebSocket
```

Three files do everything:

| File | Job |
|------|-----|
| `lib/football_tracker/premier_league_poller.ex` | Fetches data every 60s, broadcasts it |
| `lib/football_tracker_web/live/football_live.ex` | Receives broadcasts, holds state |
| `lib/football_tracker_web/live/football_live.html.heex` | Renders the UI |

**Why this is cool:** a normal app would poll a REST API from the browser, ship full JSON payloads, and need a JS framework to manage state. This does none of that — the server holds state, renders HTML, and pushes surgical diffs. The browser is just a dumb terminal that applies patches.

---

## 🚀 Setup

**Requirements**
- Elixir 1.14+
- Erlang/OTP 25+
- Node.js 18+ (for asset compilation)

→ Install Elixir: https://elixir-lang.org/install.html

```bash
# Install dependencies
mix setup

# Start the server
mix phx.server
```

Visit **http://localhost:4000** — that's it. Seriously.

---

## 🔧 Customising

### Change the league

Update `@league_id` and `@season` in `premier_league_poller.ex`:

| League | ID |
|--------|-----|
| 🏴󠁧󠁢󠁥󠁮󠁧󠁿 Premier League | `4328` |
| 🇪🇸 La Liga | `4335` |
| 🇩🇪 Bundesliga | `4331` |
| 🇮🇹 Serie A | `4332` |
| 🇫🇷 Ligue 1 | `4334` |

### Change the poll interval

Update `@poll_interval` in `premier_league_poller.ex`.

### Add more data

The GenServer state is a plain map — add a new fetcher function, broadcast the new key, add a tab to the template.

---

## 📡 API

Data comes from [TheSportsDB](https://www.thesportsdb.com) free tier — no API key, no sign-up.

```
GET /lookuptable.php?l=4328&s=2024-2025   → standings
GET /eventspastleague.php?id=4328          → recent results
GET /eventsnextleague.php?id=4328          → upcoming fixtures
```

---

## 🚢 Deployment

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

For Docker / Fly.io, see the [Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).

---

*No ads. No sign-up. No F5.*
