# Parity source confirmation (pending)

> **Draft — not the signed confirmation.** Task 1.1 remains open until the
> authoritative file, snapshot date, and write-freeze owner are confirmed in
> writing. This page records only what can be observed from the repository and
> the development copy.

## Observed facts

| Fact | Value | How observed |
| --- | --- | --- |
| Legacy file used for dry runs | `$SYNERGY_MDB` from `eOptical6DAO/.env` (`/home/paulus/Downloads/SynergyV.mdb`) | `.env` is git-ignored |
| SHA-256 | `55088a63b914f745a4bc6803ab07b11576b61e3d7c11e3f3c670bf11c2a5dd2e` | `sha256sum` |
| File size / mtime | 1,512,935,424 bytes / 2022-09-05 | `ls -l` |
| Tables / columns | 70 / 713 (192 declared `NOT NULL`) | `scripts/parity/profile-legacy-db.sh` |
| Rows in this snapshot | 7,747,518 | same |
| Branch rows | 1 | `mdb-export … Branch` |
| `PrefTxNumber` rows | 13 | `mdb-export … PrefTxNumber` |
| Legacy source tree | `eOptical6DAO/` (110 `.frm`, 42 `.bas`, 8 `.cls`) | `scripts/parity/inventory-legacy-source.sh` |
| Checked-in `eOptical6DAO/SynergyV.mdb` | schema-only, not the data source | profile run against it yields 0 rows |

## Still required for task 1.1

- [ ] Written confirmation that this file (or a successor with a different
      checksum) is the authoritative production snapshot.
- [ ] Snapshot date and the last write time of the source system.
- [ ] The person/role who owns the production write freeze and the cutover
      window.
- [ ] Re-run `scripts/parity/profile-legacy-db.sh` against the confirmed file and
      commit the resulting `legacy-profile.csv`/`.md` and checksum.
- [ ] If the checksum differs from the value above, re-run the catalogue and
      rule baselines that depend on the snapshot before signing.

Until these are signed, every profile figure and rule baseline is provisional
for the confirmed production file even though it is reproducible from this
development copy.
