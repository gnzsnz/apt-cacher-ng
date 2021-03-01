#! /usr/bin/env bash
# https://serverfault.com/questions/599103/make-a-docker-application-write-to-stdout

set -eu

# make sure log files exists to avoid issues with tail.
# truncate log files
LOGS=/var/log/apt-cacher-ng
if [ -n "$ACNG_TRUNC" ]; then
  TRUNC=$ACNG_TRUNC;
else TRUNC="<256K";fi

echo "ACNG logs truncated to: $TRUNC"
( umask 0 && truncate -s$TRUNC $LOGS/apt-cacher.{log,err} )

# tail logs and exec apt-cacher. tini will manage
tail --pid $$ -F $LOGS/* &
exec apt-cacher-ng -c /etc/apt-cacher-ng ForeGround=1
