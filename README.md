# LaunchPad — Events Dashboard

A personal, real-time events dashboard. Other apps, cron jobs, and CLI
scripts POST events into it over a REST API; you watch them land live in a
neon vaporwave feed with search, filtering, charts, and KPI cards.

Built with Ruby on Rails 8, Postgres (hosted on Supabase), and Hotwire
(Turbo Streams over Action Cable) for real-time updates — no polling,
no custom WebSocket code.

## Stack

- **Rails 8.1** — single codebase, serves both the JSON API and the dashboard
- **Postgres via Supabase** — the always-on database; Rails talks to it
  directly over the Postgres wire protocol (not through Supabase's REST layer)
- **Turbo Streams / Action Cable** — real-time feed and insight updates
- **Chart.js** (via import map, no Node/npm required) — activity charts
- **Import maps** — no JS bundler needed

## One-time setup

1. **Install Ruby 3.4** (with DevKit on Windows) and **Rails 8**:
   ```
   gem install rails
   ```

2. **Create a Supabase project** at [supabase.com](https://supabase.com) (free tier).
   Go to **Settings → Database → Connection string** and copy the URI.

3. **Configure your database connection.** Copy `.env.example` to `.env` and
   fill in `DATABASE_URL` with your Supabase connection string:
   ```
   cp .env.example .env
   ```

4. **Install gems and set up the database:**
   ```
   bundle install
   bin/rails db:migrate
   ```

5. **Seed demo data** (creates a "LaunchPad" project with ~36 sample events
   and 4 insights, using `db/seed_data/saas-demo.json`):
   ```
   bin/rails db:seed
   ```
   This prints the project's **API key** — save it, you'll need it to push
   events.

## Running it

```
bin/rails server
```

Visit **http://localhost:3000**. That's it — one process serves the
dashboard pages *and* the API. The dashboard updates in real time via Action
Cable, so leave a tab open and watch events land as you push them.

> Real-time note: the default `async` Action Cable adapter (in
> `config/cable.yml`) only works within a single running process, which is
> exactly what `bin/rails server` is. If you ever deploy this behind
> multiple server processes, switch the cable adapter to Redis (already
> wired up for the `production` environment — just set `REDIS_URL`).

## Creating a project & getting an API key

Either use the **home page** ("Create a project" form), or hit the API
directly:

```bash
curl -X POST http://localhost:3000/api/projects \
  -H "Content-Type: application/json" \
  -d '{"name": "My App"}'
```

Returns `{ "id": "...", "name": "...", "api_key": "ev_..." }`. The API key
is required on every write endpoint below.

## API reference

| Method | Path | Auth | Description |
|---|---|---|---|
| `POST` | `/api/projects` | none | Create a project, get an API key |
| `GET` | `/api/events?project=ID` | none | List events (filters: `channel`, `search`, `favorites`, `cursor`, `limit`) |
| `POST` | `/api/events` | Bearer key | Create an event, auto-creates the channel |
| `POST` | `/api/events/:id/favorite` | none | Toggle favorite |
| `POST` | `/api/events/:id/delete` | none | Delete an event |
| `POST` | `/api/insight` | Bearer key | Create/update a KPI card (upsert by title) |
| `GET` | `/api/charts?project=ID` | none | Daily activity + per-channel breakdown |

Example push:

```bash
curl -X POST http://localhost:3000/api/events \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ev_your_key_here" \
  -d '{
    "channel": "orders",
    "title": "New Order",
    "description": "Order #1234 placed by customer@example.com",
    "icon": "🛒",
    "tags": {"amount": "$49.99"}
  }'
```

## CLI tool

`bin/events` is a standalone Ruby script (no gems beyond the standard
library) for pushing events from the terminal:

```bash
ruby bin/events init --name "My App"
ruby bin/events push --api-key ev_xxx --channel signups --title "New User" --description "user@example.com signed up" --icon 👤
ruby bin/events insight --api-key ev_xxx --title "Active Users" --value "342" --icon 👥
ruby bin/events export --project PROJECT_ID --file backup.json
ruby bin/events load --api-key ev_xxx --file backup.json
```

Point it at a deployed server with `EVENTS_API_URL=https://your-app.example.com`.

## Pages

- `/` — list of projects, create new ones
- `/projects/:id/feed` — the live event feed (search, channel filter, favorites, pagination)
- `/projects/:id/charts` — daily line chart, channel doughnut, per-channel bar charts
- `/projects/:id/insight` — KPI cards, live-updating
- `/projects/:id/playground` — test the API from the browser with a live `fetch()` preview
- `/projects/:id/settings` — reveal API key, delete project

## Deploying the API so it's always on

Right now everything runs from `bin/rails server` on your machine — the
**database** is already always-on (it's Supabase), but the **Rails process**
itself only runs while your laptop does. To make the API reachable 24/7,
deploy this same Rails app to any host that runs Ruby (Render, Fly.io,
Railway, a VPS with `kamal`, etc.), pointing `DATABASE_URL` at the same
Supabase connection string. The dashboard pages can either be served by that
same deployment or you can keep running them locally against the same
database — they're already decoupled.
