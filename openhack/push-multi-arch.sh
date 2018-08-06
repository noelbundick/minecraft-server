#!/bin/sh

docker manifest create openhack/minecraft-server:1.0 openhack/minecraft-server:1.0-alpine openhack/minecraft-server:1.0-nanoserver-1803 openhack/minecraft-server:1.0-nanoserver-1709 openhack/minecraft-server:1.0-nanoserver-sac2016
docker manifest push openhack/minecraft-server:1.0

docker manifest create openhack/minecraft-server:2.0 openhack/minecraft-server:2.0-alpine openhack/minecraft-server:2.0-nanoserver-1803 openhack/minecraft-server:2.0-nanoserver-1709 openhack/minecraft-server:2.0-nanoserver-sac2016
docker manifest push openhack/minecraft-server:2.0

docker manifest create openhack/minecraft-server:latest openhack/minecraft-server:1.0-alpine openhack/minecraft-server:1.0-nanoserver-1803 openhack/minecraft-server:1.0-nanoserver-1709 openhack/minecraft-server:1.0-nanoserver-sac2016
docker manifest push openhack/minecraft-server:latest