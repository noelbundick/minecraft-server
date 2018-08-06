#!/bin/bash
set -e

if [ -z "$(ls -A /data | sed 's/lost+found//g')" ]; then
   echo "Empty data volume detected. Populating with default world"
   cp -r /default/* /data
   chown -R minecraft:minecraft /data
fi

nohup /start >/minecraft.out & 2>&1
sleep 2s
tail -n +0 -f /minecraft.out & 2>&1
grep -q "RCON running" <(tail -f /minecraft.out)
rcon-cli --host 127.0.0.1 --port 25575 --password cheesesteakjimmys ban b973ece7-93e7-477e-a69a-d22554953e89
wait $(pidof start)