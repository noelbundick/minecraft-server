#!/bin/sh

docker build -m 2G -t minecraft-server:1.0 ./1.0/nanoserver/
docker tag minecraft-server:1.0 openhack/minecraft-server:1.0
docker tag minecraft-server:1.0 openhack/minecraft-server:1.0-nanoserver
docker tag minecraft-server:1.0 openhack/minecraft-server:latest
docker push openhack/minecraft-server:1.0
docker push openhack/minecraft-server:1.0-nanoserver
docker push openhack/minecraft-server:latest

docker build -m 2G -t minecraft-server:2.0 ./2.0/nanoserver/
docker tag minecraft-server:2.0 openhack/minecraft-server:2.0
docker tag minecraft-server:2.0 openhack/minecraft-server:2.0-nanoserver
docker push openhack/minecraft-server:2.0
docker push openhack/minecraft-server:2.0-nanoserver