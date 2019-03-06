#!/bin/sh

FLOCK=/usr/bin/flock
NODE=/usr/local/bin/node
APP_PATH=/home/clwyusr/src/background-worker.js
LOCKFILE=/tmp/background-worker-lock.lck

export NODE_ENV=production

echo -n "run-worker.sh - "
date

$FLOCK -xn $LOCKFILE $NODE $APP_PATH

if [ $? -ne 0 ]
then
    echo "Execution in progress - will not run ${RUNCMD}"
    exit 1
fi

exit 0
