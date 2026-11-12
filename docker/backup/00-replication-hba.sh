#!/bin/sh
# Allow pg_basebackup replication connections from the backup container.
# Runs only while the official postgres image initializes a fresh data volume.
set -eu
echo "host replication all all scram-sha-256" >>"$PGDATA/pg_hba.conf"
