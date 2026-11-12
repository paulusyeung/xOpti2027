# Support and operations

Day-two runbook for the xOpti on-premises stack: what to look at, who owns it,
and when to escalate.

Related: [`deployment.md`](deployment.md), [`recovery.md`](recovery.md),
[`secrets.md`](secrets.md).

## Ownership

Individual names are recorded in the signed production prerequisites (task 8.4).
Until that sign-off is attached, the named role below is the accountable owner;
`TBD at 8.4` marks the fields that require a person's name.

| Area | Accountable owner | Named individual |
| --- | --- | --- |
| Host, containers, TLS edge | Infrastructure owner | TBD at 8.4 |
| PostgreSQL, bootstrap, upgrades, restore drills | Database owner | TBD at 8.4 |
| Application, API, web, releases | Application owner | TBD at 8.4 |
| Backups and off-host storage | Backup owner | TBD at 8.4 |
| POS devices, printers, scanners | Site/POS owner | TBD at 8.4 |
| Security incidents and secret rotation | Security owner | TBD at 8.4 |

Task 8.3 is not complete until every `TBD at 8.4` has a name and the document is
committed with the signed prerequisites.

## Health and monitoring

| Endpoint | Meaning | Expected |
| --- | --- | --- |
| `GET /api/health/live` | Process is alive | `200 Healthy`; do not restart on dependency failure |
| `GET /api/health/ready` | PostgreSQL reachable, schema baseline current, file volume writable | `200 Healthy`; otherwise `503` with a reason in the body |
| `GET /api/v1/*` | Business traffic | `503 https://errors.xopti/service-unavailable` while readiness fails; `401` for anonymous requests when healthy |

Readiness reasons map to actions:

- `platform.schema_baseline is missing` → run `--bootstrap` (fresh database) or
  restore the baseline (existing database).
- `Schema baseline … does not match the deployed script` → deploy the matching
  release pair (image + schema), or restore the matching script.
- `ConnectionStrings:XOptiDatabase is not configured` / probe failure → fix the
  secret or database availability.
- `File volume not writable` → remount `filevolume`; check ownership and disk.

## Logs

- The API writes JSON to stdout with a `CorrelationId` scope on every request
  (`x-correlation-id` response header, or the inbound value when supplied).
- Each request produces one completion entry:
  `HTTP {Method} {Path} responded {StatusCode} in {ElapsedMs} ms`.
  Paths only: query strings, bodies, credentials, card data, and prescription
  fields are never logged.
- Exception mapper entries include the correlation id and method/path, not the
  request body.
- Free-form values that may contain identifiers should be passed through
  `PiiRedaction.Redact` (email, SIN, phone, card patterns) before logging.

Useful commands:

```bash
docker compose -p xopti logs -f api | jq 'select(.Scopes[]?.CorrelationId == "<id>")'
docker compose -p xopti logs --since 30m api
docker compose -p xopti logs caddy
scripts/backup-status.sh
```

Support investigations must use the correlation id, never a password, card
number, or prescription detail.

## Certificates

- Caddy renews internal certificates automatically.
- Root certificate distribution: `/data/caddy/pki/authorities/local/root.crt`
  from the `caddy_data` volume.
- Renewal check: `docker compose -p xopti logs caddy | grep -i certificate`.
- If the internal CA is rotated, redistribute the new root to every POS client
  before the old certificate expires; see [`secrets.md`](secrets.md).

## Backups

- Owner: Backup owner (named at 8.4).
- Schedule: daily base backup, continuous WAL archiving, 14-day retention by
  default.
- Alerting: `XOPTI_ALERT_WEBHOOK` receives failures; `scripts/backup-status.sh`
  exits non-zero when the last success is older than 36 hours.
- Restore drills: Database owner runs the procedure in
  [`recovery.md`](recovery.md) and records the result there.

## Escalation

| Severity | Example | Response |
| --- | --- | --- |
| S1 — outage | POS cannot sign in or post sales; readiness `503`; database down | Page Infrastructure and Database owners immediately; open an incident log with the correlation ids |
| S2 — degraded | Reports slow, one printer down, backup stale | Notify the relevant owner within the business day; schedule a fix |
| S3 — routine | Question, cosmetic defect, documentation gap | Normal backlog |

Incident record must include: start/end time, affected stores, correlation ids,
root cause, data-loss assessment (restore point if any), and follow-up actions.
Security incidents additionally involve the Security owner and secret rotation.

## Common tasks

| Task | Command |
| --- | --- |
| Start/stop the stack | `docker compose -p xopti up -d` / `down` |
| Apply app migrations | `docker compose -p xopti run --rm api --migrate` |
| Re-prove bootstrap idempotence | `docker compose -p xopti run --rm api --bootstrap` |
| Schema drift gate | `scripts/schema-drift.sh` |
| Backup status | `scripts/backup-status.sh` |
| TLS edge check | `scripts/tls-check.sh` |
| Secret scan | `scripts/scan-secrets.sh --image xopti-api:<tag>` |
| Full release gate | `scripts/ci.sh` |
