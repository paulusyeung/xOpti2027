# Deployment

This is the on-premises deployment runbook for xOpti: one Linux host, Docker
Compose, PostgreSQL 17, the ASP.NET Core API, the nginx-served SPA, and an
optional Caddy TLS edge. Following it in order produces a working stack from an
empty host; every step names its verification.

Related: [`secrets.md`](secrets.md), [`recovery.md`](recovery.md),
[`support.md`](support.md).

## 1. Host prerequisites

| Item | Requirement |
| --- | --- |
| OS | 64-bit Linux with Docker Engine 27+ and Compose v2 (`docker compose version`) |
| CPU / RAM | 4 vCPU / 8 GB minimum for the stack plus PostgreSQL |
| Disk | 100 GB free for the database volume, file volume, base backups, and WAL archive |
| Network | A stable LAN address; ports 80/443 (or 8088/8443 for the TLS test profile) reachable by POS clients |
| Time | NTP enabled; the API and database must agree on UTC |
| Tools | `curl`, `git`, `openssl` (for CA inspection) |
| Off-host storage | Backup target for `docker/compose.backup.yml`; if unavailable, record the degraded RPO in the signed prerequisites |

Verify:

```bash
docker version --format '{{.Server.Version}}'
docker compose version
df -h /var/lib/docker
timedatectl status
```

## 2. Get the release and secrets

```bash
git clone <release-repository> /opt/xopti
cd /opt/xopti
git checkout <release-tag>
```

Create a protected environment file **outside the repository** (mode 0600),
for example `/etc/xopti/xopti.env`:

```bash
XOPTI_PG_PASSWORD=<generated-password>
XOPTI_TLS_HOST=xopti.example.internal
# Optional analytics licence; leave unset to disable the pivot feature.
# XOPTI_WPT_LICENSE_KEY=<licence>
```

Do not add database passwords, licence keys, or certificate material to the
repository. See [`secrets.md`](secrets.md) for the full inventory and rotation.

## 3. Build and start

```bash
cd /opt/xopti
set -a; . /etc/xopti/xopti.env; set +a

docker compose -p xopti -f docker/compose.yml build
docker compose -p xopti -f docker/compose.yml up -d postgres
```

Wait for PostgreSQL, then bootstrap the empty database with the production
command (idempotent; safe to re-run):

```bash
docker compose -p xopti -f docker/compose.yml run --rm api --bootstrap
docker compose -p xopti -f docker/compose.yml run --rm api --bootstrap   # proves idempotence
```

Expected output: `Bootstrapped schema baseline …` followed by
`already current … nothing to do.` A different checksum fails before any DDL and
reports the expected and found checksums.

Start the application:

```bash
docker compose -p xopti -f docker/compose.yml up -d api web
docker compose -p xopti -f docker/compose.yml ps
```

Verify:

```bash
curl -fsS http://127.0.0.1:8080/api/health/live        # Healthy
curl -fsS http://127.0.0.1:8080/api/health/ready       # Healthy
```

If readiness says `platform.schema_baseline is missing`, step 3's bootstrap did
not run. If it says `does not match the deployed script`, the image and the
database are from different releases; deploy the matching pair (section 6).

## 4. TLS edge

The repository ships a Caddy profile with an internal CA:

```bash
docker compose -p xopti -f docker/compose.yml -f docker/compose.tls.yml up -d --build
```

- Plain HTTP on `XOPTI_TLS_HTTP_PORT` (default 8088) redirects with `308` to
  HTTPS on `XOPTI_TLS_HTTPS_PORT` (default 8443).
- The SPA and API remain same-origin; nginx forwards the edge scheme so the
  session and CSRF cookies are `Secure`.
- Distribute the root certificate from the `caddy_data` volume to POS clients:

```bash
docker compose -p xopti -f docker/compose.yml -f docker/compose.tls.yml \
  exec caddy cat /data/caddy/pki/authorities/local/root.crt > /etc/xopti/internal-ca.crt
```

Verify the whole edge (redirect, HTTPS health, CSRF rejection, Secure cookie):

```bash
scripts/tls-check.sh
```

If the customer operates an approved reverse proxy instead, terminate TLS there,
forward `X-Forwarded-Proto: https`, and keep the same-origin `/api` routing.
Never expose the API container directly.

## 5. Smoke checks

```bash
# Health
curl -fsS https://xopti.example.internal/api/health/live
curl -fsS https://xopti.example.internal/api/health/ready

# Sign-in and branch read (use a real account, not a smoke account)
curl -fsS -c /tmp/cookies https://xopti.example.internal/api/v1/auth/csrf-token
# POST /api/v1/auth/sign-in with the CSRF token, then:
curl -fsS -b /tmp/cookies https://xopti.example.internal/api/v1/branches?pageSize=1
```

Also confirm one receipt and one label print on the approved printer, and one
scanner read on the approved workstation. Device validation is recorded in
`docs/parity/devices.csv`; tasks 4.2/4.3 must be signed before go-live.

## 6. Upgrades

xOpti migrations are additive. Never run `--migrate` or `--bootstrap` at API
startup.

1. Take a base backup (or confirm the scheduled one is recent):
   `scripts/backup-status.sh`
2. Check out the new release tag and build the images.
3. Apply app-owned migrations:
   `docker compose -p xopti -f docker/compose.yml run --rm api --migrate`
4. Run the drift gate against the deployed schema:
   `scripts/schema-drift.sh` (requires `XOPTI_DATABASE_URL`)
5. Recreate `api` and `web`; confirm `/api/health/ready` is `Healthy`.
6. Run the smoke checks in section 5.

Rollback: redeploy the previous tag. If the previous release cannot read the new
schema, restore the pre-upgrade backup per [`recovery.md`](recovery.md).

## 7. Backups

Start the WAL + base-backup profile alongside the stack:

```bash
docker compose -p xopti -f docker/compose.yml -f docker/compose.backup.yml up -d
scripts/backup-status.sh
```

Backups are not optional. `backup-status.sh` exits non-zero when the last success
is older than the alert threshold (default 36 h) or the last run failed.
Configure `XOPTI_ALERT_WEBHOOK` so failures reach the on-call channel.

## 8. Troubleshooting

| Symptom | Check | Action |
| --- | --- | --- |
| Readiness `Unhealthy`, liveness `Healthy` | `docker compose logs api` | Schema baseline missing/outdated, database unreachable, or file volume unwritable; fix the dependency, do not restart blindly |
| Business endpoints return `503 https://errors.xopti/service-unavailable` | `/api/health/ready` | Run the bootstrap or deploy the matching schema; the `detail` names the reason |
| `password authentication failed` | `XOPTI_PG_PASSWORD`, `ConnectionStrings__XOptiDatabase` | Fix the secret; URL-form passwords must be percent-encoded |
| Sign-in works, session lost after restart | Data Protection key volume | Ensure `XOPTI_DATA_PROTECTION_KEYS` is on a persistent volume |
| TLS handshake error | Caddy logs, certificate SAN | Connect with the configured host name; re-issue or redistribute the internal CA |
| Smoke stack fails to seed | `XOPTI_ALLOW_SMOKE_SEED` | Seed only disposable databases; never seed production |

## Verification checklist

- [ ] `docker compose ps` shows postgres healthy, api and web running
- [ ] `/api/health/live` and `/api/health/ready` both `Healthy`
- [ ] Bootstrap re-run reports `already current`
- [ ] `scripts/tls-check.sh` passes (or the approved proxy equivalent)
- [ ] `scripts/backup-status.sh` exits 0 and shows a recent backup
- [ ] One real sign-in and branch read succeed
- [ ] No secrets in the repository or image (`scripts/scan-secrets.sh --image <tag>`)
