#!/bin/sh

docker build -t minecraft-server:1.0 ./1.0/alpine/
docker tag minecraft-server:1.0 openhack/minecraft-server:1.0
docker tag minecraft-server:1.0 openhack/minecraft-server:1.0-alpine
docker tag minecraft-server:1.0 openhack/minecraft-server:latest
docker push openhack/minecraft-server:1.0
docker push openhack/minecraft-server:1.0-alpine
docker push openhack/minecraft-server:latest

docker build -t minecraft-server:2.0 ./2.0/alpine/
docker tag minecraft-server:2.0 openhack/minecraft-server:2.0
docker tag minecraft-server:2.0 openhack/minecraft-server:2.0-alpine
docker push openhack/minecraft-server:2.0
docker push openhack/minecraft-server:2.0-alpine