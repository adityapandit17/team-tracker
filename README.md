# Team Tracker

A Rails app for running a development team: people, projects, allocations, billing,
skills, and the client-lead pipeline — in one place, with role-based access and a
full audit trail.

## Requirements

* Ruby 4.0.6
* PostgreSQL 14+
* Bundler

Tailwind and the JavaScript dependencies need no Node install — the app uses
[tailwindcss-rails](https://github.com/rails/tailwindcss-rails) (standalone CLI) and
[importmap-rails](https://github.com/rails/importmap-rails).

## Getting started

```bash
bundle install
cp .env.example .env          # defaults to a local Postgres user named `developer`
bin/rails db:prepare          # create, migrate, and seed
bin/dev                       # Rails + Tailwind watcher + job worker on :3000
```

Then open http://localhost:3000 and sign in.

`bin/dev` runs the processes in `Procfile.dev` (web server, Tailwind watcher, job
worker) with [foreman](https://github.com/ddollar/foreman), installing it on first run
if it is missing.

### Seeded accounts

The seeds create a realistic roster and one login per role. All use the password
`password123`.

| Email | Role | Scope |
|---|---|---|
| `admin@teamtracker.test` | Admin | Everything |
| `manager@teamtracker.test` | Manager | Everything, including accounts |
| `lead@teamtracker.test` | Team lead | Own profile plus their team |
| `developer@teamtracker.test` | Developer | Own profile, skills, and projects |

## Features

**People**

* **Developers** — profile, stack, availability, rating, hourly cost, and a report
  card covering feedback, assessments, growth plans, 1:1s, and action items.
* **Hierarchy** — org chart of who reports to whom, drawn from each developer's team
  lead, with collapsible teams.
* **Skill Matrix** — proficiency grid with inline editing.

**Delivery**

* **Projects** — an editable table: change any cell (name, dates, billing, status,
  developers) and it saves immediately without a page reload. Columns can be shown or
  hidden per browser.
* **Project timeline** — reconstructs who held each project role over time from the
  audit trail, and totals the time each developer spent on the project.
* **Allocations & Bench** — percentage allocations per developer with a bench view for
  anyone under 50%.
* **Client Leads** — sales pipeline with per-developer win rate and conversion.

**Money**

* **Billings** — monthly or fixed-price billing entries per project, moving through
  `draft` → `pending` → `cleared`.
* **Utilization** — hours billed against hours allocated, plus revenue, cost, and margin.
* **Incentives** — fixed lead incentives. Configure a free-project threshold and an
  amount per project on a lead, mark projects as eligible, and the payout is
  `(eligible projects − free threshold) × amount`.

**Governance**

* **Audit Log** — every create, update, and destroy across all models, recording who
  changed what, when, and from which IP. Visible to admins and managers.

## Roles and permissions

Four roles are defined on `User`: `admin`, `manager`, `team_lead`, and `developer`.
Permissions live in a single table in `app/controllers/concerns/authorizable.rb`; add a
capability there and check it with `can?(:capability)` in controllers and views.

Team leads see themselves and their assigned team, and can add developers (who are
auto-assigned to them). Admins and managers assign developers to leads, and can promote
a developer to team lead from their profile page.

## Background jobs

Jobs run on [Solid Queue](https://github.com/rails/solid_queue), backed by a separate
`queue` database defined in `config/database.yml`.

Start a worker with `bin/jobs` (already included in `bin/dev`). The recurring schedule
lives in `config/recurring.yml`:

| Job | Schedule | Purpose |
|---|---|---|
| `GenerateMonthlyDraftBillingsJob` | 00:05 on the 1st | Draft billing rows for the month that just closed (idempotent) |
| `SolidQueue::Job.clear_finished_in_batches` | Hourly | Prune finished jobs |

## Testing

```bash
bin/rails test
```

## Configuration

`.env` is loaded by [dotenv-rails](https://github.com/bkeepers/dotenv) in development
and test. `.env.example` documents the available settings:

| Variable | Purpose |
|---|---|
| `DB_HOST`, `DB_USERNAME`, `DB_PASSWORD` | Database connection |
| `SECRET_KEY_BASE` | Required in production |

## Notable code

| Path | What it holds |
|---|---|
| `app/controllers/concerns/authorizable.rb` | Permission table and record scoping |
| `app/models/concerns/auditable.rb` | Audit trail, included by `ApplicationRecord` |
| `app/models/current.rb` | Per-request actor used for audit attribution |
| `app/models/project_timeline.rb` | Rebuilds developer stints from audits |
| `app/models/lead_incentive_report.rb` | Incentive calculation |
| `app/models/org_chart.rb` | Reporting hierarchy |
| `app/models/utilization_report.rb` | Cost, revenue, and margin |
| `app/javascript/controllers/` | Stimulus controllers (inline edit, column toggles, org chart) |

## Stack

Rails 7.1 · PostgreSQL · Hotwire (Turbo + Stimulus) · importmap · Propshaft ·
Tailwind CSS · Devise · Solid Queue
