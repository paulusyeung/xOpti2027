# Backup, restore, and disaster recovery

Targets from the production baseline: **RPO ≤ 15 minutes**, **RTO ≤ 4 hours**.
Continuous WAL archiving provides the RPO; base backups plus WAL replay provide
the restore point; the procedures below are the RTO path.

Related: [`deployment.md`](deployment.md), [`support.md`](support.md).

## What is backed up

| Component | Mechanism | Location |
| --- | --- | --- |
| Database base backups | `pg_basebackup` on the `backup` service (`docker/compose.backup.yml`), default daily | `backups` volume, `base/<UTC timestamp>/` |
| Write-ahead log | PostgreSQL `archive_mode=on`, `archive_command` copies to `wal-archive` | `walarchive` volume |
| File attachments | `filevolume` bind/volume | host volume; snapshot with the same schedule as base backups |
| Application configuration | environment/secret store and `caddy_data` | protected host paths |
| Migration reports | `tools/legacy-migration/reports/` | repository and release artifacts |

Retention defaults to 14 days (`XOPTI_BACKUP_RETENTION_DAYS`). Adjust only with
the signed prerequisites; 14 days covers the agreed recovery window.

Check status:

```bash
scripts/backup-status.sh          # exits non-zero when stale or failed
scripts/backup-status.sh --json   # raw status document
```

A failed run writes `status: failed`, logs `ALERT: base backup failed: …`, and
POSTs to `XOPTI_ALERT_WEBHOOK` when configured.

## Restore procedure (point in time)

Work on an isolated host. Do not restore over the live data directory.

1. **Select the restore point.** List base backups:
   `docker run --rm -v xopti_backups:/b alpine ls -1 /b/base | sort`
   Choose the newest base at or before the desired time.
2. **Stop writers.** Stop `api`, `web`, and the `backup` service (not PostgreSQL).
3. **Restore the base backup** into a fresh data directory:
   ```bash
   docker run --rm -v xopti_backups:/b -v xopti_restore:/r alpine \
     sh -c 'mkdir -p /r && tar -xzf /b/base/<stamp>/base.tar.gz -C /r'
   ```
   (The base backup is `-Ft -z`; repeat for tablespace tarballs if any exist.)
4. **Replay WAL to the target time.** Create `postgresql.auto.conf` in the
   restored directory with:
   ```
   restore_command = 'cp /var/lib/postgresql/wal-archive/%f %p'
   recovery_target_time = '2026-11-12 20:00:00+00'
   recovery_target_action = 'promote'
   ```
   Start PostgreSQL against the restored directory with the archive mounted
   read-only. Wait for `database system is ready to accept connections`, then
   confirm the recovery target in the log.
5. **Verify integrity.**
   - `SELECT pg_is_in_recovery();` → `false`
   - Row counts for the key tables match the recorded snapshot: `tx_header`,
     `tx_details`, `tx_payment`, `inventory`, `customer`, `pref_tx_number`.
   - `SELECT version, checksum FROM platform.schema_baseline;` matches the
     deployed release.
   - Run `scripts/schema-drift.sh` against the restored database.
6. **Switch traffic** only after the checks pass and the application smoke
   checks (`/api/health/ready`, sign-in, branch read) succeed against the
   restored instance.
7. **Record the drill**: restore point, base backup stamp, WAL range, start/end
   time, measured duration, verifier, and any gaps.

### Recorded drills

| Date | Restore point | Duration | Result | Evidence |
| --- | --- | --- | --- | --- |
| _pending_ | | | | Task 7.6 has not run; the procedure above is ready to execute. |

Task 7.6 remains open until this table has a real drill with row-count and
checksum evidence.

## Rollback

Application rollback is redeploying the previous release tag. Migrations are
additive (`ALTER TABLE … ADD COLUMN` / new tables), so the previous application
can run against the newer schema.

Roll back the database only when a release performed a destructive change; that
requires restoring the pre-upgrade base backup and replaying to the point before
the upgrade. The xOpti migrations contain no `DropTable`/`DropColumn`, so this is
expected to be unnecessary; treat any destructive migration as a defect.

## Disaster scenarios

| Scenario | First action | Recovery |
| --- | --- | --- |
| Host loss | Provision the spare host, restore secrets and volumes | Restore newest base + WAL, verify, switch DNS/IP |
| Database corruption | Stop the API to prevent writes | Restore the last consistent base; do not attempt in-place repair without a verified copy |
| Ransomware / compromise | Isolate the host, preserve evidence, rotate all secrets | Restore from off-host backups taken before the incident; rebuild from a clean image |
| Storage full | Free space, then investigate retention | Base backups and WAL archive are the first consumers; never delete the only copy |
| Failed upgrade | Redeploy the previous tag | Restore only if the schema is unreadable by the old release |

## Verification checklist

- [ ] `scripts/backup-status.sh` exits 0 and shows a recent successful base
- [ ] WAL archive contains segments and `pg_stat_archiver.failed_count = 0`
- [ ] Restore reproduced the expected row counts and baseline checksum
- [ ] Restore duration is recorded in the drill table
- [ ] Secrets used during the drill are rotated afterwards
