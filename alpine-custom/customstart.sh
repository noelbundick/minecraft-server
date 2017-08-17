#!/bin/sh
set -e

if [ -z "$(ls -A /data)" ]; then
   echo "Empty data volume detected. Populating with default world"
   cp -r /default/* /data
   chown -R minecraft:minecraft /data
fi

. /start