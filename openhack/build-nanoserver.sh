#!/bin/sh

docker build -m 2G -t openhack/minecraft-server:1.0-nanoserver ./1.0/nanoserver/
docker push openhack/minecraft-server:1.0-nanoserver

docker build -m 2G -t openhack/minecraft-server:2.0-nanoserver ./2.0/nanoserver/
docker push openhack/minecraft-server:2.0-nanoserver