#!/bin/bash
rm -f $DUMP_PATH
echo Dumping database...
mysqldump -h"$REMOTE_MYSQL_ADDR" -P"$REMOTE_MYSQL_PORT" -uroot -p"$REMOTE_MYSQL_ROOT_PASSWORD" $REMOTE_MYSQL_DATABASE > $DUMP_PATH
echo Database dumped. Beginning sync...
/app/sync.sh
echo Sync complete.