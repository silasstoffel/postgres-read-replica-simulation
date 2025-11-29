#!/bin/sh
set -e

# 1. Creates replication user database
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replicator_pass';
EOSQL

# 2. Adding permission in the pg_hba.conf to replicator user.
echo "host replication replicator 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"

# 3. Reload configuration to apply the changes in pg_hba.conf
#pg_ctl -D "$PGDATA" reload
