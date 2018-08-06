#!/bin/sh

docker build -t openhack/minecraft-server:1.0-alpine --target openhack-1.0 ./alpine/
docker push openhack/minecraft-server:1.0-alpine

docker build -t openhack/minecraft-server:2.0-alpine --target openhack-2.0 ./alpine/
docker push openhack/minecraft-server:2.0-alpine