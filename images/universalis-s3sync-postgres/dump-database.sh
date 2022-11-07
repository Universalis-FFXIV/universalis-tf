#!/bin/bash
rm -f $DUMP_PATH
echo Dumping database...
PGPASSWORD="$REMOTE_POSTGRES_PASSWORD" pg_dump -Fc -d "$REMOTE_POSTGRES_DATABASE" -h "$REMOTE_POSTGRES_HOST" -U "$REMOTE_POSTGRES_USER" > $DUMP_PATH
echo Database dumped. Beginning sync...
/app/sync.sh
echo Sync complete.