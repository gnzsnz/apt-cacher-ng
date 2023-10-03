#!/bin/bash
#
# https://serverfault.com/questions/599103/make-a-docker-application-write-to-stdout

set -eu

# make sure log files exists to avoid issues with tail.
# truncate log files
LOGS=/var/log/apt-cacher-ng
if [ -n "$ACNG_TRUNC" ]; then
  TRUNC="$ACNG_TRUNC";
else
  TRUNC="<256K"
fi

echo "ACNG logs truncated to: $TRUNC"
(umask 0 && truncate -s"$TRUNC" "$LOGS"/apt-cacher.{log,err} "$LOGS"/cron.log)

# run cron, tail logs and exec apt-cacher. tini will manage
cron -L 15 -f 2>&1 $LOGS/cron.log &
tail --pid $$ -F $LOGS/apt-cacher.log $LOGS/apt-cacher.err $LOGS/cron.log &
exec apt-cacher-ng -c /etc/apt-cacher-ng ForeGround=1
