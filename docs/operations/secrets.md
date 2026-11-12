# Secrets and configuration hygiene

Production secrets are supplied only through protected runtime configuration
(environment variables injected by the orchestrator or an operator-controlled
secret store). They are never committed, baked into an image, or written to a
client bundle.

Verify with:

```bash
scripts/scan-secrets.sh                       # tracked files
scripts/scan-secrets.sh --image xopti-api:tag # built image
```

The scan runs in `scripts/ci.sh`. The web build independently checks the bundle
for licence keys and credential patterns (`web/xOpti.Web/scripts/check-build-output.mjs`).

## Secret inventory

| Secret | Runtime key | Where it lives | Owner |
| --- | --- | --- | --- |
| PostgreSQL application password | `XOPTI_PG_PASSWORD`, `ConnectionStrings__XOptiDatabase` | compose secret/env, not in git | Database owner (named in `support.md`) |
| ASP.NET Data Protection key ring | persisted key directory | host volume outside the image | Application owner |
| TLS CA and certificates | `caddy_data` volume | edge host only | Infrastructure owner |
| Analytics (WebPivotTable) licence key | `XOPTI_WPT_LICENSE_KEY` | web container env at deploy time | Application owner |
| Smoke seed password | `XOPTI_SMOKE_PASSWORD` | disposable CI/smoke stack only | CI owner |

Notes:

- `appsettings.Development.json` is git-ignored and excluded from publish
  (`xOpti.Api.csproj`, `.dockerignore`); the image scan would fail if it leaked.
- The session cookie is authenticated by the Data Protection key ring. That ring
  must be persisted across restarts; otherwise every restart signs all users out.
  Mount it at `XOPTI_DATA_PROTECTION_KEYS` (see `deployment.md`).
- The smoke password (`SmokeSeed.DefaultPassword`) is a disposable test
  credential. It is not a production secret and `--seed-smoke` refuses to run
  without `XOPTI_ALLOW_SMOKE_SEED=1`.

## Rotation

Rotate without downtime where possible; every rotation records who, when, and
why in the operations log.

### PostgreSQL password

1. Create a new password and update the secret store entry
   (`XOPTI_PG_PASSWORD`, and the full `ConnectionStrings__XOptiDatabase` if used).
2. Apply it to the database role first:
   `ALTER ROLE xopti_app PASSWORD '<new>';`
3. Restart the API (rolling restart is fine once both old and new are accepted;
   PostgreSQL accepts only the latest, so restart immediately after the ALTER).
4. Confirm `/api/health/ready` is `Healthy` and a smoke sign-in succeeds.
5. Revoke/remove the old value from the secret store.

### Data Protection key ring

Rotate by generating a new key and retiring old ones. Persist the directory on a
volume; deleting it invalidates every session and CSRF cookie (users must sign in
again). Record the rotation window because it is user-visible.

### TLS certificate / internal CA

Caddy renews its internal certificates automatically. To rotate the internal CA,
remove `caddy_data/caddy/pki/authorities/local` on the edge host, restart Caddy,
and redistribute the new root certificate to clients. Never commit the CA key.

### Analytics licence key

Replace `XOPTI_WPT_LICENSE_KEY` in the web container environment and restart the
web container. The key is read at runtime into `/config.json`; it is not part of
the image. Confirm the analytics route still loads and the bundle check passes.

### Smoke credentials

Rotate by setting `XOPTI_SMOKE_PASSWORD` for a smoke run; the value is never used
by a production deployment. Delete the smoke database and stack after the run
(`docker compose ... down -v`).
